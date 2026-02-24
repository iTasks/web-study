package com.yelp.assistant.search;

import com.yelp.assistant.model.Photo;
import com.yelp.assistant.model.PhotoSearchResult;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class PhotoHybridRetrievalService {

    private final List<Photo> photos = new CopyOnWriteArrayList<>();

    public void addPhoto(Photo photo) { photos.add(photo); }

    public List<PhotoSearchResult> search(String query, String businessId, int topK) {
        List<PhotoSearchResult> results = new ArrayList<>();
        for (Photo p : photos) {
            if (!p.businessId().equals(businessId)) continue;
            double cap = captionScore(query, p.caption());
            results.add(new PhotoSearchResult(p, cap, cap));
        }
        results.sort(Comparator.comparingDouble(PhotoSearchResult::combinedScore).reversed());
        return results.subList(0, Math.min(topK, results.size()));
    }

    private double captionScore(String query, String caption) {
        if (caption == null || caption.isEmpty()) return 0;
        Set<String> qTokens = new HashSet<>(Arrays.asList(query.toLowerCase().split("\\s+")));
        Set<String> cTokens = new HashSet<>(Arrays.asList(caption.toLowerCase().split("\\s+")));
        if (qTokens.isEmpty()) return 0;
        long overlap = qTokens.stream().filter(cTokens::contains).count();
        return Math.round((double) overlap / qTokens.size() * 10000.0) / 10000.0;
    }
}
