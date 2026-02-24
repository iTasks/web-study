using YelpAiAssistant.Models;

namespace YelpAiAssistant.Orchestration;

public record EvidenceBundle(
    BusinessData? Business,
    double StructuredScore,
    List<ReviewSearchResult> ReviewResults,
    List<PhotoSearchResult> PhotoResults,
    double FinalScore,
    List<string> ConflictNotes);

public class AnswerOrchestrator
{
    public EvidenceBundle Orchestrate(
        List<StructuredSearchResult> structured,
        List<ReviewSearchResult> reviews,
        List<PhotoSearchResult> photos)
    {
        BusinessData? biz = null;
        double structScore = 0;
        if (structured.Count > 0) { biz = structured[0].Business; structScore = structured[0].Score; }

        var conflicts = new List<string>();
        if (biz is not null)
        {
            foreach (var (key, val) in biz.Amenities)
            {
                if (val) continue;
                var label = key.Replace("_", " ");
                if (reviews.Any(r => r.Review.Text.Contains(label, StringComparison.OrdinalIgnoreCase)))
                    conflicts.Add($"Canonical data: no {label}. Some reviews mention '{label}' — treat as anecdotal.");
            }
        }

        double avgReview = reviews.Count > 0 ? reviews.Average(r => r.SimilarityScore) : 0;
        double avgPhoto  = photos.Count  > 0 ? photos.Average(p => p.CombinedScore)    : 0;
        double finalScore = Math.Round(0.4 * structScore + 0.3 * avgReview + 0.3 * avgPhoto, 4);

        return new EvidenceBundle(biz, structScore, reviews, photos, finalScore, conflicts);
    }
}
