package com.yelp.assistant.search;

import com.yelp.assistant.model.Review;
import com.yelp.assistant.model.ReviewSearchResult;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class ReviewVectorSearchService {

    private final List<Review> reviews = new CopyOnWriteArrayList<>();

    public void addReview(Review review) { reviews.add(review); }

    public List<ReviewSearchResult> search(String query, String businessId, int topK) {
        double[] qVec = embed(query);
        List<ReviewSearchResult> results = new ArrayList<>();
        for (Review r : reviews) {
            if (!r.businessId().equals(businessId)) continue;
            double sim = cosine(qVec, embed(r.text()));
            results.add(new ReviewSearchResult(r, Math.round(sim * 10000.0) / 10000.0));
        }
        results.sort(Comparator.comparingDouble(ReviewSearchResult::similarityScore).reversed());
        return results.subList(0, Math.min(topK, results.size()));
    }

    private double[] embed(String text) {
        String[] tokens = text.toLowerCase().split("\\s+");
        double[] vec = new double[16];
        for (String tok : tokens) {
            for (int i = 0; i < tok.length(); i++) {
                vec[i % 16] += tok.charAt(i) / 1000.0;
            }
        }
        return vec;
    }

    private double cosine(double[] a, double[] b) {
        double dot = 0, na = 0, nb = 0;
        for (int i = 0; i < a.length; i++) {
            dot += a[i] * b[i];
            na += a[i] * a[i];
            nb += b[i] * b[i];
        }
        return (na == 0 || nb == 0) ? 0 : dot / (Math.sqrt(na) * Math.sqrt(nb));
    }
}
