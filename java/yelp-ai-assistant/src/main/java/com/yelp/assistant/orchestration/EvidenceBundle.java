package com.yelp.assistant.orchestration;

import com.yelp.assistant.model.*;

import java.util.ArrayList;
import java.util.List;

public record EvidenceBundle(
    BusinessData business,
    double structuredScore,
    List<ReviewSearchResult> reviewResults,
    List<PhotoSearchResult> photoResults,
    double finalScore,
    List<String> conflictNotes
) {
    public static EvidenceBundle build(
        List<StructuredSearchResult> structured,
        List<ReviewSearchResult> reviews,
        List<PhotoSearchResult> photos
    ) {
        BusinessData biz = null;
        double structScore = 0;
        if (!structured.isEmpty()) {
            biz = structured.get(0).business();
            structScore = structured.get(0).score();
        }

        List<String> conflicts = new ArrayList<>();
        if (biz != null) {
            for (var entry : biz.amenities().entrySet()) {
                String label = entry.getKey().replace("_", " ");
                if (!entry.getValue()) {
                    for (ReviewSearchResult rr : reviews) {
                        if (rr.review().text().toLowerCase().contains(label)) {
                            conflicts.add("Canonical data: no " + label +
                                ". Some reviews mention '" + label + "' — treat as anecdotal.");
                            break;
                        }
                    }
                }
            }
        }

        double avgReview = reviews.isEmpty() ? 0 :
            reviews.stream().mapToDouble(ReviewSearchResult::similarityScore).average().orElse(0);
        double avgPhoto = photos.isEmpty() ? 0 :
            photos.stream().mapToDouble(PhotoSearchResult::combinedScore).average().orElse(0);

        double finalScore = Math.round((0.4 * structScore + 0.3 * avgReview + 0.3 * avgPhoto) * 10000.0) / 10000.0;

        return new EvidenceBundle(biz, structScore, reviews, photos, finalScore, conflicts);
    }
}
