package com.yelp.assistant.intent;

import com.yelp.assistant.model.QueryIntent;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@Component
public class IntentClassifier {

    private static final Map<QueryIntent, List<Pattern>> SIGNALS = Map.of(
        QueryIntent.OPERATIONAL, compile(
            "\\bopen\\b", "\\bclosed?\\b", "\\bhours?\\b", "\\bclose[sd]?\\b",
            "\\btoday\\b", "\\bright\\s+now\\b", "\\bcurrently\\b", "\\btonight\\b",
            "\\bmorning\\b", "\\bevening\\b",
            "\\bmonday\\b", "\\btuesday\\b", "\\bwednesday\\b", "\\bthursday\\b",
            "\\bfriday\\b", "\\bsaturday\\b", "\\bsunday\\b"
        ),
        QueryIntent.AMENITY, compile(
            "\\bpatio\\b", "\\bheater[sd]?\\b", "\\bheated\\b", "\\bparking\\b",
            "\\bwifi\\b", "\\bwi-fi\\b", "\\bwheelchair\\b", "\\baccessible\\b",
            "\\boutdoor\\b", "\\bindoor\\b", "\\bseating\\b", "\\bhave\\b",
            "\\bdo\\s+they\\b", "\\bdoes\\s+it\\b", "\\bamenitie[sd]?\\b"
        ),
        QueryIntent.QUALITY, compile(
            "\\bgood\\b", "\\bbad\\b", "\\bgreat\\b", "\\bworth\\b",
            "\\breview[sd]?\\b", "\\brating[sd]?\\b", "\\bdate\\b", "\\bromantic\\b",
            "\\bfamily\\b", "\\brecommend\\b", "\\bfood\\b", "\\bservice\\b",
            "\\batmosphere\\b", "\\bambiance\\b"
        ),
        QueryIntent.PHOTO, compile(
            "\\bphoto[sd]?\\b", "\\bpicture[sd]?\\b", "\\bimage[sd]?\\b",
            "\\bshow\\s+me\\b", "\\bvisual[sd]?\\b", "\\bgallery\\b"
        )
    );

    // Tie-breaking priority
    private static final List<QueryIntent> PRIORITY = List.of(
        QueryIntent.OPERATIONAL, QueryIntent.AMENITY, QueryIntent.PHOTO, QueryIntent.QUALITY
    );

    public QueryIntent classify(String query) {
        String q = query.toLowerCase();
        QueryIntent best = QueryIntent.UNKNOWN;
        int bestScore = 0;
        for (QueryIntent intent : PRIORITY) {
            int score = score(q, SIGNALS.get(intent));
            if (score > bestScore) {
                bestScore = score;
                best = intent;
            }
        }
        return best;
    }

    private int score(String query, List<Pattern> patterns) {
        if (patterns == null) return 0;
        int count = 0;
        for (Pattern p : patterns) {
            if (p.matcher(query).find()) count++;
        }
        return count;
    }

    private static List<Pattern> compile(String... patterns) {
        return java.util.Arrays.stream(patterns)
            .map(p -> Pattern.compile(p, Pattern.CASE_INSENSITIVE))
            .toList();
    }
}
