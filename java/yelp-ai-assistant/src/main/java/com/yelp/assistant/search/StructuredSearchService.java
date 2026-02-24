package com.yelp.assistant.search;

import com.yelp.assistant.model.BusinessData;
import com.yelp.assistant.model.StructuredSearchResult;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class StructuredSearchService {

    private final Map<String, BusinessData> store = new ConcurrentHashMap<>();

    public void addBusiness(BusinessData business) {
        store.put(business.businessId(), business);
    }

    public List<StructuredSearchResult> search(String query, String businessId) {
        BusinessData biz = store.get(businessId);
        if (biz == null) return List.of();

        String q = query.toLowerCase();
        List<String> matched = new ArrayList<>();

        if (containsAny(q, "open", "close", "hour", "time")) matched.add("hours");
        for (String key : biz.amenities().keySet()) {
            String label = key.replace("_", " ");
            if (q.contains(label) || q.contains(key)) matched.add("amenities." + key);
        }
        if (containsAny(q, "address", "location", "where", "phone")) matched.add("address");

        double score = matched.isEmpty() ? 0.5 : 1.0;
        return List.of(new StructuredSearchResult(biz, matched, score));
    }

    private boolean containsAny(String s, String... subs) {
        for (String sub : subs) if (s.contains(sub)) return true;
        return false;
    }
}
