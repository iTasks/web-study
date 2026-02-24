package com.yelp.assistant.model;

import java.util.List;
import java.util.Map;

public record BusinessData(
    String businessId,
    String name,
    String address,
    String phone,
    String priceRange,
    List<BusinessHours> hours,
    Map<String, Boolean> amenities,
    List<String> categories,
    double rating,
    int reviewCount
) {}
