package com.yelp.assistant.model;

public record Photo(
    String photoId,
    String businessId,
    String url,
    String caption
) {}
