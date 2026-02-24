package com.yelp.assistant.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record QueryResponse(
    String answer,
    double confidence,
    QueryIntent intent,
    EvidenceSummary evidence,
    @JsonProperty("latency_ms") double latencyMs
) {}
