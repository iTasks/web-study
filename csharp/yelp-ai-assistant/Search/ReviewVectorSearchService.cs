using YelpAiAssistant.Models;

namespace YelpAiAssistant.Search;

public class ReviewVectorSearchService
{
    private readonly List<Review> _reviews = [];
    private readonly object _lock = new();

    public void AddReview(Review r) { lock (_lock) _reviews.Add(r); }

    public IEnumerable<ReviewSearchResult> Search(string query, string businessId, int topK)
    {
        List<Review> snapshot;
        lock (_lock) snapshot = [.._reviews];

        var qVec = Embed(query);
        return snapshot
            .Where(r => r.BusinessId == businessId)
            .Select(r => new ReviewSearchResult(r, Math.Round(Cosine(qVec, Embed(r.Text)), 4)))
            .OrderByDescending(r => r.SimilarityScore)
            .Take(topK);
    }

    private static double[] Embed(string text)
    {
        var tokens = text.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        var vec = new double[16];
        foreach (var tok in tokens)
            for (int i = 0; i < tok.Length; i++)
                vec[i % 16] += tok[i] / 1000.0;
        return vec;
    }

    private static double Cosine(double[] a, double[] b)
    {
        double dot = 0, na = 0, nb = 0;
        for (int i = 0; i < a.Length; i++) { dot += a[i]*b[i]; na += a[i]*a[i]; nb += b[i]*b[i]; }
        return (na == 0 || nb == 0) ? 0 : dot / (Math.Sqrt(na) * Math.Sqrt(nb));
    }
}
