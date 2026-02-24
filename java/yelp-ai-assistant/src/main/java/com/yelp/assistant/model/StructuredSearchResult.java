package com.yelp.assistant.model;

import java.util.List;

public record StructuredSearchResult(
    BusinessData business,
    List<String> matchedFields,
    double score
) {}
