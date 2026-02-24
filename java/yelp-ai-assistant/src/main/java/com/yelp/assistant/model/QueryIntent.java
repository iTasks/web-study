package com.yelp.assistant.model;

public enum QueryIntent {
    OPERATIONAL("operational"),
    AMENITY("amenity"),
    QUALITY("quality"),
    PHOTO("photo"),
    UNKNOWN("unknown");

    private final String value;

    QueryIntent(String value) { this.value = value; }

    public String getValue() { return value; }

    @Override
    public String toString() { return value; }
}
