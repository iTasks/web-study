use crate::models::{EvidenceSummary, QueryIntent, QueryResponse};
use crate::orchestration::EvidenceBundle;

/// Mock RAG/LLM service that generates human-readable answers from an EvidenceBundle.
pub struct RagService;

impl RagService {
    pub fn new() -> Self {
        RagService
    }

    pub fn generate_answer(
        &self,
        query: &str,
        intent: &QueryIntent,
        bundle: &EvidenceBundle,
        latency_ms: f64,
    ) -> QueryResponse {
        let (answer, confidence) = match intent {
            QueryIntent::Operational => self.answer_operational(bundle),
            QueryIntent::Amenity => self.answer_amenity(query, bundle),
            QueryIntent::Quality => self.answer_quality(bundle),
            QueryIntent::Photo => self.answer_photo(bundle),
            QueryIntent::Unknown => self.answer_unknown(bundle),
        };

        QueryResponse {
            answer,
            confidence,
            intent: intent.to_string(),
            evidence: EvidenceSummary {
                structured: bundle.business.is_some(),
                reviews_used: bundle.review_results.len(),
                photos_used: bundle.photo_results.len(),
            },
            latency_ms,
        }
    }

    // -----------------------------------------------------------------------
    // Intent-specific answer generators
    // -----------------------------------------------------------------------

    fn answer_operational(&self, bundle: &EvidenceBundle) -> (String, f64) {
        if let Some(business) = &bundle.business {
            if business.hours.is_empty() {
                return (
                    format!("{} hours are not available.", business.name),
                    0.3,
                );
            }
            let lines: Vec<String> = business
                .hours
                .iter()
                .map(|h| {
                    if h.is_closed {
                        format!("{}: Closed", h.day)
                    } else {
                        format!("{}: {} – {}", h.day, h.open_time, h.close_time)
                    }
                })
                .collect();
            (
                format!("{} hours:\n{}", business.name, lines.join("\n")),
                0.9,
            )
        } else {
            ("No business information found.".to_string(), 0.1)
        }
    }

    fn answer_amenity(&self, query: &str, bundle: &EvidenceBundle) -> (String, f64) {
        if let Some(business) = &bundle.business {
            let q = query.to_lowercase();
            // Check if the query mentions a specific amenity
            for (amenity, available) in &business.amenities {
                if q.contains(&amenity.to_lowercase()) {
                    let answer = if *available {
                        format!("Yes, {} has {}.", business.name, amenity)
                    } else {
                        format!("No, {} does not have {}.", business.name, amenity)
                    };
                    return (answer, 0.85);
                }
            }
            // Fall back to listing all available amenities
            let available: Vec<String> = business
                .amenities
                .iter()
                .filter(|(_, v)| **v)
                .map(|(k, _)| k.clone())
                .collect();
            let answer = if available.is_empty() {
                format!("{} has no listed amenities.", business.name)
            } else {
                format!("{} offers: {}.", business.name, available.join(", "))
            };
            (answer, 0.7)
        } else {
            ("No amenity information available.".to_string(), 0.1)
        }
    }

    fn answer_quality(&self, bundle: &EvidenceBundle) -> (String, f64) {
        if bundle.review_results.is_empty() {
            if let Some(business) = &bundle.business {
                return (
                    format!(
                        "{} has a rating of {:.1} stars.",
                        business.name, business.rating
                    ),
                    0.6,
                );
            }
            return ("No review information available.".to_string(), 0.1);
        }

        let avg_rating: f64 = bundle.review_results.iter().map(|r| r.review.rating).sum::<f64>()
            / bundle.review_results.len() as f64;

        let snippets: Vec<String> = bundle
            .review_results
            .iter()
            .take(2)
            .map(|r| {
                let text = if r.review.text.len() > 80 {
                    format!("{}...", &r.review.text[..80])
                } else {
                    r.review.text.clone()
                };
                format!("\"{}\" ({}★)", text, r.review.rating)
            })
            .collect();

        let answer = format!(
            "Based on reviews, average rating is {:.1}★. Highlights: {}",
            avg_rating,
            snippets.join("; ")
        );
        (answer, 0.8)
    }

    fn answer_photo(&self, bundle: &EvidenceBundle) -> (String, f64) {
        if bundle.photo_results.is_empty() {
            return ("No photos available.".to_string(), 0.2);
        }
        let lines: Vec<String> = bundle
            .photo_results
            .iter()
            .map(|p| format!("• {} — {}", p.photo.caption, p.photo.url))
            .collect();
        (format!("Photos available:\n{}", lines.join("\n")), 0.75)
    }

    fn answer_unknown(&self, bundle: &EvidenceBundle) -> (String, f64) {
        if let Some(business) = &bundle.business {
            let answer = format!(
                "{} is located at {}. Rating: {:.1}★ ({} reviews). Phone: {}.",
                business.name,
                business.address,
                business.rating,
                business.review_count,
                business.phone
            );
            (answer, 0.5)
        } else {
            (
                "I couldn't find relevant information for your query.".to_string(),
                0.1,
            )
        }
    }
}
