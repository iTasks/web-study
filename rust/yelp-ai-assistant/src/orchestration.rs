use crate::models::{BusinessData, PhotoSearchResult, ReviewSearchResult, RoutingDecision,
                    StructuredSearchResult};

/// All evidence gathered for a single query.
#[derive(Debug, Clone)]
pub struct EvidenceBundle {
    pub business: Option<BusinessData>,
    pub structured_score: f64,
    pub review_results: Vec<ReviewSearchResult>,
    pub photo_results: Vec<PhotoSearchResult>,
    pub final_score: f64,
    pub conflict_notes: Vec<String>,
}

pub struct AnswerOrchestrator;

impl AnswerOrchestrator {
    pub fn new() -> Self {
        AnswerOrchestrator
    }

    /// Combines search results into an `EvidenceBundle`.
    /// `_decision` is reserved for future routing-aware conflict detection logic.
    /// final_score = 0.4 * structured + 0.3 * avg_review_sim + 0.3 * avg_photo_sim
    pub fn orchestrate(
        &self,
        structured: Vec<StructuredSearchResult>,
        reviews: Vec<ReviewSearchResult>,
        photos: Vec<PhotoSearchResult>,
        _decision: &RoutingDecision,
    ) -> EvidenceBundle {
        let business = structured.first().map(|r| r.business.clone());
        let structured_score = structured.first().map(|r| r.score).unwrap_or(0.0);

        let avg_review_sim = if reviews.is_empty() {
            0.0
        } else {
            reviews.iter().map(|r| r.similarity_score).sum::<f64>() / reviews.len() as f64
        };

        let avg_photo_sim = if photos.is_empty() {
            0.0
        } else {
            photos.iter().map(|p| p.combined_score).sum::<f64>() / photos.len() as f64
        };

        let final_score =
            0.4 * structured_score + 0.3 * avg_review_sim + 0.3 * avg_photo_sim;

        EvidenceBundle {
            business,
            structured_score,
            review_results: reviews,
            photo_results: photos,
            final_score,
            conflict_notes: Vec::new(),
        }
    }
}
