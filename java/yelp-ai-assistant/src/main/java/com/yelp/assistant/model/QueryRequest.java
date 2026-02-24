package com.yelp.assistant.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record QueryRequest(
    @NotBlank @Size(min = 1, max = 1000) String query,
    @JsonProperty("business_id") @NotBlank String businessId
) {}
