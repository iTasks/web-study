package com.yelp.assistant.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EvidenceSummary(
    boolean structured,
    @JsonProperty("reviews_used") int reviewsUsed,
    @JsonProperty("photos_used") int photosUsed
) {}
