use std::collections::HashMap;
use std::fmt;

use serde::{Deserialize, Serialize};

// ---------------------------------------------------------------------------
// Intent
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum QueryIntent {
    Operational,
    Amenity,
    Quality,
    Photo,
    Unknown,
}

impl fmt::Display for QueryIntent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let s = match self {
            QueryIntent::Operational => "operational",
            QueryIntent::Amenity => "amenity",
            QueryIntent::Quality => "quality",
            QueryIntent::Photo => "photo",
            QueryIntent::Unknown => "unknown",
        };
        write!(f, "{}", s)
    }
}

// ---------------------------------------------------------------------------
// Business / core data
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BusinessHours {
    pub day: String,
    pub open_time: String,
    pub close_time: String,
    pub is_closed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BusinessData {
    pub business_id: String,
    pub name: String,
    pub address: String,
    pub phone: String,
    pub price_range: String,
    pub hours: Vec<BusinessHours>,
    pub amenities: HashMap<String, bool>,
    pub categories: Vec<String>,
    pub rating: f64,
    pub review_count: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Review {
    pub review_id: String,
    pub business_id: String,
    pub user_id: String,
    pub rating: f64,
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Photo {
    pub photo_id: String,
    pub business_id: String,
    pub url: String,
    pub caption: String,
}

// ---------------------------------------------------------------------------
// Search results
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StructuredSearchResult {
    pub business: BusinessData,
    pub matched_fields: Vec<String>,
    pub score: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReviewSearchResult {
    pub review: Review,
    pub similarity_score: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhotoSearchResult {
    pub photo: Photo,
    pub caption_score: f64,
    pub image_similarity: f64,
    pub combined_score: f64,
}

// ---------------------------------------------------------------------------
// API request / response
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, Deserialize)]
pub struct QueryRequest {
    pub query: String,
    pub business_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvidenceSummary {
    pub structured: bool,
    pub reviews_used: usize,
    pub photos_used: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QueryResponse {
    pub answer: String,
    pub confidence: f64,
    pub intent: String,
    pub evidence: EvidenceSummary,
    pub latency_ms: f64,
}

// ---------------------------------------------------------------------------
// Routing
// ---------------------------------------------------------------------------

#[derive(Debug, Clone)]
pub struct RoutingDecision {
    pub intent: QueryIntent,
    pub use_structured: bool,
    pub use_review_vector: bool,
    pub use_photo_hybrid: bool,
}
