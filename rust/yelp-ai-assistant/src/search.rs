use std::collections::{HashMap, HashSet};

use crate::models::{BusinessData, Photo, PhotoSearchResult, Review, ReviewSearchResult,
                    StructuredSearchResult};

// ---------------------------------------------------------------------------
// Shared text helpers
// ---------------------------------------------------------------------------

fn tokenize(text: &str) -> Vec<String> {
    text.to_lowercase()
        .split_whitespace()
        .map(|w| w.trim_matches(|c: char| !c.is_alphanumeric()).to_string())
        .filter(|w| !w.is_empty())
        .collect()
}

fn bag_of_words_similarity(a: &[String], b: &[String]) -> f64 {
    let mut a_counts: HashMap<&str, usize> = HashMap::new();
    let mut b_counts: HashMap<&str, usize> = HashMap::new();

    for token in a {
        *a_counts.entry(token.as_str()).or_insert(0) += 1;
    }
    for token in b {
        *b_counts.entry(token.as_str()).or_insert(0) += 1;
    }

    let dot: f64 = a_counts
        .iter()
        .filter_map(|(k, v)| b_counts.get(k).map(|bv| (*v * bv) as f64))
        .sum();

    let mag_a: f64 = a_counts.values().map(|v| (*v as f64).powi(2)).sum::<f64>().sqrt();
    let mag_b: f64 = b_counts.values().map(|v| (*v as f64).powi(2)).sum::<f64>().sqrt();

    if mag_a == 0.0 || mag_b == 0.0 {
        0.0
    } else {
        dot / (mag_a * mag_b)
    }
}

// ---------------------------------------------------------------------------
// StructuredSearchService
// ---------------------------------------------------------------------------

pub struct StructuredSearchService {
    businesses: HashMap<String, BusinessData>,
}

impl StructuredSearchService {
    pub fn new() -> Self {
        StructuredSearchService {
            businesses: HashMap::new(),
        }
    }

    pub fn add_business(&mut self, business: BusinessData) {
        self.businesses
            .insert(business.business_id.clone(), business);
    }

    /// Returns matching businesses. When `business_id` is provided the result
    /// always includes that business (ensures operational queries get data).
    pub fn search(
        &self,
        query: &str,
        business_id: Option<&str>,
    ) -> Vec<StructuredSearchResult> {
        let query_lower = query.to_lowercase();
        let mut results = Vec::new();

        for (id, business) in &self.businesses {
            if let Some(bid) = business_id {
                if id != bid {
                    continue;
                }
            }

            let mut matched_fields: Vec<String> = Vec::new();
            let mut score = 0.0_f64;

            if business.name.to_lowercase().contains(&query_lower) {
                matched_fields.push("name".to_string());
                score += 0.5;
            }
            for cat in &business.categories {
                if cat.to_lowercase().contains(&query_lower) {
                    matched_fields.push("categories".to_string());
                    score += 0.3;
                    break;
                }
            }

            // When filtering by business_id always return the business
            if business_id.is_some() {
                if matched_fields.is_empty() {
                    matched_fields.push("business_id".to_string());
                    score = 0.1;
                }
                results.push(StructuredSearchResult {
                    business: business.clone(),
                    matched_fields,
                    score,
                });
            } else if !matched_fields.is_empty() {
                results.push(StructuredSearchResult {
                    business: business.clone(),
                    matched_fields,
                    score,
                });
            }
        }

        results.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap_or(std::cmp::Ordering::Equal));
        results
    }
}

// ---------------------------------------------------------------------------
// ReviewVectorSearchService
// ---------------------------------------------------------------------------

pub struct ReviewVectorSearchService {
    reviews: Vec<Review>,
}

impl ReviewVectorSearchService {
    pub fn new() -> Self {
        ReviewVectorSearchService {
            reviews: Vec::new(),
        }
    }

    pub fn add_review(&mut self, review: Review) {
        self.reviews.push(review);
    }

    /// Bag-of-words cosine similarity search.
    pub fn search(
        &self,
        query: &str,
        business_id: Option<&str>,
        top_k: usize,
    ) -> Vec<ReviewSearchResult> {
        let query_tokens = tokenize(query);

        let mut results: Vec<ReviewSearchResult> = self
            .reviews
            .iter()
            .filter(|r| business_id.map_or(true, |bid| r.business_id == bid))
            .map(|review| {
                let review_tokens = tokenize(&review.text);
                let similarity_score = bag_of_words_similarity(&query_tokens, &review_tokens);
                ReviewSearchResult {
                    review: review.clone(),
                    similarity_score,
                }
            })
            .collect();

        results.sort_by(|a, b| {
            b.similarity_score
                .partial_cmp(&a.similarity_score)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        results.truncate(top_k);
        results
    }
}

// ---------------------------------------------------------------------------
// PhotoHybridRetrievalService
// ---------------------------------------------------------------------------

pub struct PhotoHybridRetrievalService {
    photos: Vec<Photo>,
}

impl PhotoHybridRetrievalService {
    pub fn new() -> Self {
        PhotoHybridRetrievalService { photos: Vec::new() }
    }

    pub fn add_photo(&mut self, photo: Photo) {
        self.photos.push(photo);
    }

    /// Caption keyword overlap + proxy image similarity score.
    pub fn search(
        &self,
        query: &str,
        business_id: Option<&str>,
        top_k: usize,
    ) -> Vec<PhotoSearchResult> {
        let query_tokens: HashSet<String> = tokenize(query).into_iter().collect();

        let mut results: Vec<PhotoSearchResult> = self
            .photos
            .iter()
            .filter(|p| business_id.map_or(true, |bid| p.business_id == bid))
            .map(|photo| {
                let caption_tokens: HashSet<String> =
                    tokenize(&photo.caption).into_iter().collect();
                let overlap = query_tokens.intersection(&caption_tokens).count();
                let caption_score = if query_tokens.is_empty() {
                    0.0
                } else {
                    overlap as f64 / query_tokens.len() as f64
                };
                // Proxy image similarity based on caption relevance
                let image_similarity = 0.5 + caption_score * 0.3;
                let combined_score = 0.6 * caption_score + 0.4 * image_similarity;
                PhotoSearchResult {
                    photo: photo.clone(),
                    caption_score,
                    image_similarity,
                    combined_score,
                }
            })
            .collect();

        results.sort_by(|a, b| {
            b.combined_score
                .partial_cmp(&a.combined_score)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        results.truncate(top_k);
        results
    }
}
