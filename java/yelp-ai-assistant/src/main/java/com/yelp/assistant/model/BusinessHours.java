package com.yelp.assistant.model;

public record BusinessHours(
    String day,
    String openTime,
    String closeTime,
    boolean isClosed
) {
    public BusinessHours(String day, String openTime, String closeTime) {
        this(day, openTime, closeTime, false);
    }
}
