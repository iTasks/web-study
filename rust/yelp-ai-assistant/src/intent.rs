use std::time::Instant;

use regex::Regex;

use crate::models::QueryIntent;

/// Classifies a query into one of the four intent buckets using regex keyword matching.
pub struct IntentClassifier {
    operational_patterns: Vec<Regex>,
    amenity_patterns: Vec<Regex>,
    quality_patterns: Vec<Regex>,
    photo_patterns: Vec<Regex>,
}

impl IntentClassifier {
    pub fn new() -> Self {
        let operational_patterns = vec![
            Regex::new(r"(?i)\bopen\b").unwrap(),
            Regex::new(r"(?i)\bclosed?\b").unwrap(),
            Regex::new(r"(?i)\bhours?\b").unwrap(),
            Regex::new(r"(?i)\btoday\b").unwrap(),
            Regex::new(r"(?i)\bwhen\b").unwrap(),
            Regex::new(r"(?i)\bschedule\b").unwrap(),
        ];
        let amenity_patterns = vec![
            Regex::new(r"(?i)\bpatio\b").unwrap(),
            Regex::new(r"(?i)\bparking\b").unwrap(),
            Regex::new(r"(?i)\bwifi\b").unwrap(),
            Regex::new(r"(?i)\bheated\b").unwrap(),
            Regex::new(r"(?i)\bhave\b").unwrap(),
            Regex::new(r"(?i)does it").unwrap(),
            Regex::new(r"(?i)\bamenity\b").unwrap(),
            Regex::new(r"(?i)\bamenities\b").unwrap(),
        ];
        let quality_patterns = vec![
            Regex::new(r"(?i)\bgood\b").unwrap(),
            Regex::new(r"(?i)\bgreat\b").unwrap(),
            Regex::new(r"(?i)\breviews?\b").unwrap(),
            Regex::new(r"(?i)\brating\b").unwrap(),
            Regex::new(r"(?i)\bdate\b").unwrap(),
            Regex::new(r"(?i)\bfood\b").unwrap(),
            Regex::new(r"(?i)\bworth\b").unwrap(),
            Regex::new(r"(?i)\brecommend\b").unwrap(),
        ];
        let photo_patterns = vec![
            Regex::new(r"(?i)\bphoto\b").unwrap(),
            Regex::new(r"(?i)\bpicture\b").unwrap(),
            Regex::new(r"(?i)show me").unwrap(),
            Regex::new(r"(?i)\bimage\b").unwrap(),
            Regex::new(r"(?i)look like").unwrap(),
        ];

        IntentClassifier {
            operational_patterns,
            amenity_patterns,
            quality_patterns,
            photo_patterns,
        }
    }

    /// Returns `(intent, confidence, latency_ms)`.
    /// Tie-breaking priority: OPERATIONAL > AMENITY > PHOTO > QUALITY.
    pub fn classify(&self, query: &str) -> (QueryIntent, f64, f64) {
        let start = Instant::now();

        let op_count = self
            .operational_patterns
            .iter()
            .filter(|p| p.is_match(query))
            .count();
        let am_count = self
            .amenity_patterns
            .iter()
            .filter(|p| p.is_match(query))
            .count();
        let qu_count = self
            .quality_patterns
            .iter()
            .filter(|p| p.is_match(query))
            .count();
        let ph_count = self
            .photo_patterns
            .iter()
            .filter(|p| p.is_match(query))
            .count();

        let latency_ms = start.elapsed().as_secs_f64() * 1000.0;

        let total = (op_count + am_count + qu_count + ph_count) as f64;
        if total == 0.0 {
            return (QueryIntent::Unknown, 0.0, latency_ms);
        }

        let max_count = op_count.max(am_count).max(qu_count).max(ph_count);

        let (intent, count) = if op_count == max_count {
            (QueryIntent::Operational, op_count)
        } else if am_count == max_count {
            (QueryIntent::Amenity, am_count)
        } else if ph_count == max_count {
            (QueryIntent::Photo, ph_count)
        } else {
            (QueryIntent::Quality, qu_count)
        };

        let confidence = count as f64 / total;
        (intent, confidence, latency_ms)
    }
}
