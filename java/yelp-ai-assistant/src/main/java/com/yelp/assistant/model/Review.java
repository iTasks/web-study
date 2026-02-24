package com.yelp.assistant.model;

public record Review(
    String reviewId,
    String businessId,
    String userId,
    double rating,
    String text
) {}
