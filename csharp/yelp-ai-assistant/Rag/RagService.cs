using YelpAiAssistant.Models;
using YelpAiAssistant.Orchestration;

namespace YelpAiAssistant.Rag;

public class RagService
{
    public string GenerateAnswer(string query, QueryIntent intent, EvidenceBundle bundle) =>
        intent switch
        {
            QueryIntent.Operational => AnswerOperational(bundle),
            QueryIntent.Amenity     => AnswerAmenity(query, bundle),
            QueryIntent.Quality     => AnswerQuality(bundle),
            QueryIntent.Photo       => AnswerPhoto(bundle),
            _                       => AnswerUnknown(bundle),
        };

    private static string AnswerOperational(EvidenceBundle b)
    {
        if (b.Business?.Hours.Count > 0)
        {
            var parts = b.Business.Hours.Select(h => h.IsClosed
                ? $"{Cap(h.Day)}: Closed"
                : $"{Cap(h.Day)}: {h.OpenTime}–{h.CloseTime}");
            return $"Business hours for {b.Business.Name}: {string.Join("; ", parts)}.";
        }
        return "Business hours are not available.";
    }

    private static string AnswerAmenity(string query, EvidenceBundle b)
    {
        if (b.Business?.Amenities.Count > 0)
        {
            var q = query.ToLowerInvariant();
            foreach (var (key, val) in b.Business.Amenities)
            {
                var label = key.Replace("_", " ");
                if (!q.Contains(label) && !q.Contains(key)) continue;
                var status = val ? "Yes" : "No";
                var ans = $"{b.Business.Name} — {label}: {status} (canonical).";
                if (b.ConflictNotes.Count > 0) ans += " Note: " + b.ConflictNotes[0];
                return ans;
            }
        }
        return "Amenity information is not available in our records.";
    }

    private static string AnswerQuality(EvidenceBundle b)
    {
        if (b.ReviewResults.Count > 0)
        {
            var avg = b.ReviewResults.Average(r => r.Review.Rating);
            return $"Based on {b.ReviewResults.Count} relevant review(s), average rating: {avg:F1}/5.";
        }
        return "No relevant reviews found to assess quality.";
    }

    private static string AnswerPhoto(EvidenceBundle b)
    {
        if (b.PhotoResults.Count > 0)
        {
            var captions = b.PhotoResults
                .Where(p => !string.IsNullOrEmpty(p.Photo.Caption))
                .Take(3)
                .Select(p => p.Photo.Caption);
            var joined = string.Join("; ", captions);
            if (!string.IsNullOrEmpty(joined))
                return $"Found {b.PhotoResults.Count} photo(s): {joined}";
        }
        return "No matching photos found.";
    }

    private static string AnswerUnknown(EvidenceBundle b)
    {
        if (b.Business is not null)
            return $"{b.Business.Name} is located at {b.Business.Address}. Rating: {b.Business.Rating:F1}/5. Phone: {b.Business.Phone}.";
        return "I could not find a specific answer to your question.";
    }

    private static string Cap(string s) =>
        string.IsNullOrEmpty(s) ? s : char.ToUpperInvariant(s[0]) + s[1..];
}
