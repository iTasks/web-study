package com.yelp.assistant.rag;

import com.yelp.assistant.model.*;
import com.yelp.assistant.orchestration.EvidenceBundle;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
public class RagService {

    public String generateAnswer(String query, QueryIntent intent, EvidenceBundle bundle) {
        return switch (intent) {
            case OPERATIONAL -> answersOperational(bundle);
            case AMENITY     -> answerAmenity(query, bundle);
            case QUALITY     -> answerQuality(bundle);
            case PHOTO       -> answerPhoto(bundle);
            default          -> answerUnknown(bundle);
        };
    }

    private String answersOperational(EvidenceBundle b) {
        if (b.business() != null && !b.business().hours().isEmpty()) {
            String hours = b.business().hours().stream()
                .map(h -> h.isClosed()
                    ? capitalize(h.day()) + ": Closed"
                    : capitalize(h.day()) + ": " + h.openTime() + "–" + h.closeTime())
                .collect(Collectors.joining("; "));
            return "Business hours for " + b.business().name() + ": " + hours + ".";
        }
        return "Business hours are not available.";
    }

    private String answerAmenity(String query, EvidenceBundle b) {
        if (b.business() != null && !b.business().amenities().isEmpty()) {
            String q = query.toLowerCase();
            for (var entry : b.business().amenities().entrySet()) {
                String label = entry.getKey().replace("_", " ");
                if (q.contains(label) || q.contains(entry.getKey())) {
                    String status = entry.getValue() ? "Yes" : "No";
                    String ans = b.business().name() + " — " + label + ": " + status + " (canonical).";
                    if (!b.conflictNotes().isEmpty()) ans += " Note: " + b.conflictNotes().get(0);
                    return ans;
                }
            }
        }
        return "Amenity information is not available in our records.";
    }

    private String answerQuality(EvidenceBundle b) {
        if (!b.reviewResults().isEmpty()) {
            double avg = b.reviewResults().stream()
                .mapToDouble(r -> r.review().rating()).average().orElse(0);
            return String.format("Based on %d relevant review(s), average rating: %.1f/5.",
                b.reviewResults().size(), avg);
        }
        return "No relevant reviews found to assess quality.";
    }

    private String answerPhoto(EvidenceBundle b) {
        if (!b.photoResults().isEmpty()) {
            String captions = b.photoResults().stream()
                .map(p -> p.photo().caption())
                .filter(c -> c != null && !c.isEmpty())
                .limit(3)
                .collect(Collectors.joining("; "));
            if (!captions.isEmpty())
                return "Found " + b.photoResults().size() + " photo(s): " + captions;
        }
        return "No matching photos found.";
    }

    private String answerUnknown(EvidenceBundle b) {
        if (b.business() != null) {
            return String.format("%s is located at %s. Rating: %.1f/5. Phone: %s.",
                b.business().name(), b.business().address(),
                b.business().rating(), b.business().phone());
        }
        return "I could not find a specific answer to your question.";
    }

    private String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}
