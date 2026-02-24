package com.yelp.assistant.model;

public record RoutingDecision(
    QueryIntent intent,
    boolean useStructured,
    boolean useReviewVector,
    boolean usePhotoHybrid
) {}
