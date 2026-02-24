package com.yelp.assistant.cache;

import com.yelp.assistant.model.QueryResponse;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.*;

@Component
public class QueryCache {

    private static final int MAX_SIZE = 10_000;
    private static final long TTL_SECONDS = 300;

    private record Entry(QueryResponse value, long expiresAt) {}

    private final LinkedHashMap<String, Entry> store = new LinkedHashMap<>(256, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, Entry> eldest) {
            return size() > MAX_SIZE;
        }
    };

    public synchronized Optional<QueryResponse> get(String businessId, String query) {
        String key = key(businessId, query);
        Entry entry = store.get(key);
        if (entry == null) return Optional.empty();
        if (Instant.now().getEpochSecond() > entry.expiresAt()) {
            store.remove(key);
            return Optional.empty();
        }
        return Optional.of(entry.value());
    }

    public synchronized void set(String businessId, String query, QueryResponse response) {
        String key = key(businessId, query);
        store.put(key, new Entry(response, Instant.now().getEpochSecond() + TTL_SECONDS));
    }

    public synchronized int size() { return store.size(); }

    private String key(String businessId, String query) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest((businessId + ":" + query).getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash, 0, 8);
        } catch (NoSuchAlgorithmException e) {
            return businessId + ":" + query;
        }
    }
}
