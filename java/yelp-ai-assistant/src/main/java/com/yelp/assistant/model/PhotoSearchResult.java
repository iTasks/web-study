package com.yelp.assistant.model;

public record PhotoSearchResult(
    Photo photo,
    double captionScore,
    double imageSimilarity
) {
    public double combinedScore() {
        return 0.5 * captionScore + 0.5 * imageSimilarity;
    }
}
