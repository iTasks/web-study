use crate::models::{QueryIntent, RoutingDecision};

/// Maps an intent to the set of search services that should be invoked.
pub struct QueryRouter;

impl QueryRouter {
    pub fn new() -> Self {
        QueryRouter
    }

    pub fn decide(&self, intent: QueryIntent) -> RoutingDecision {
        match intent {
            QueryIntent::Operational => RoutingDecision {
                intent,
                use_structured: true,
                use_review_vector: false,
                use_photo_hybrid: false,
            },
            QueryIntent::Amenity => RoutingDecision {
                intent,
                use_structured: true,
                use_review_vector: true,
                use_photo_hybrid: true,
            },
            QueryIntent::Quality => RoutingDecision {
                intent,
                use_structured: false,
                use_review_vector: true,
                use_photo_hybrid: false,
            },
            QueryIntent::Photo => RoutingDecision {
                intent,
                use_structured: false,
                use_review_vector: false,
                use_photo_hybrid: true,
            },
            QueryIntent::Unknown => RoutingDecision {
                intent,
                use_structured: true,
                use_review_vector: true,
                use_photo_hybrid: false,
            },
        }
    }
}
