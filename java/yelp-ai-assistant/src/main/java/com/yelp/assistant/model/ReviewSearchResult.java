package com.yelp.assistant.model;

public record ReviewSearchResult(
    Review review,
    double similarityScore
) {}
