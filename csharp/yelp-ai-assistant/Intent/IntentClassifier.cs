using System.Text.RegularExpressions;
using YelpAiAssistant.Models;

namespace YelpAiAssistant.Intent;

public class IntentClassifier
{
    private static readonly (QueryIntent Intent, Regex[] Patterns)[] Signals =
    [
        (QueryIntent.Operational, Compile(
            @"\bopen\b", @"\bclosed?\b", @"\bhours?\b", @"\bclose[sd]?\b",
            @"\btoday\b", @"\bright\s+now\b", @"\bcurrently\b", @"\btonight\b",
            @"\bmorning\b", @"\bevening\b",
            @"\bmonday\b", @"\btuesday\b", @"\bwednesday\b", @"\bthursday\b",
            @"\bfriday\b", @"\bsaturday\b", @"\bsunday\b")),
        (QueryIntent.Amenity, Compile(
            @"\bpatio\b", @"\bheater[sd]?\b", @"\bheated\b", @"\bparking\b",
            @"\bwifi\b", @"\bwi-fi\b", @"\bwheelchair\b", @"\baccessible\b",
            @"\boutdoor\b", @"\bindoor\b", @"\bseating\b", @"\bhave\b",
            @"\bdo\s+they\b", @"\bdoes\s+it\b", @"\bamenitie[sd]?\b")),
        (QueryIntent.Quality, Compile(
            @"\bgood\b", @"\bbad\b", @"\bgreat\b", @"\bworth\b",
            @"\breview[sd]?\b", @"\brating[sd]?\b", @"\bdate\b", @"\bromantic\b",
            @"\bfamily\b", @"\brecommend\b", @"\bfood\b", @"\bservice\b",
            @"\batmosphere\b", @"\bambiance\b")),
        (QueryIntent.Photo, Compile(
            @"\bphoto[sd]?\b", @"\bpicture[sd]?\b", @"\bimage[sd]?\b",
            @"\bshow\s+me\b", @"\bvisual[sd]?\b", @"\bgallery\b")),
    ];

    // Tie-breaking priority
    private static readonly QueryIntent[] Priority =
        [QueryIntent.Operational, QueryIntent.Amenity, QueryIntent.Photo, QueryIntent.Quality];

    public QueryIntent Classify(string query)
    {
        var best = QueryIntent.Unknown;
        int bestScore = 0;
        foreach (var intent in Priority)
        {
            int score = Score(query, intent);
            if (score > bestScore) { bestScore = score; best = intent; }
        }
        return best;
    }

    private static int Score(string query, QueryIntent intent)
    {
        var group = Array.Find(Signals, s => s.Intent == intent);
        return group.Patterns?.Count(p => p.IsMatch(query)) ?? 0;
    }

    private static Regex[] Compile(params string[] patterns) =>
        patterns.Select(p => new Regex(p, RegexOptions.IgnoreCase | RegexOptions.Compiled)).ToArray();
}
