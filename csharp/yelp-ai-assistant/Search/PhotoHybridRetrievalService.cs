using YelpAiAssistant.Models;

namespace YelpAiAssistant.Search;

public class PhotoHybridRetrievalService
{
    private readonly List<Photo> _photos = [];
    private readonly object _lock = new();

    public void AddPhoto(Photo p) { lock (_lock) _photos.Add(p); }

    public IEnumerable<PhotoSearchResult> Search(string query, string businessId, int topK)
    {
        List<Photo> snapshot;
        lock (_lock) snapshot = [.._photos];

        return snapshot
            .Where(p => p.BusinessId == businessId)
            .Select(p => { var c = CaptionScore(query, p.Caption); return new PhotoSearchResult(p, c, c); })
            .OrderByDescending(r => r.CombinedScore)
            .Take(topK);
    }

    private static double CaptionScore(string query, string caption)
    {
        if (string.IsNullOrEmpty(caption)) return 0;
        var qToks = new HashSet<string>(query.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries));
        var cToks = new HashSet<string>(caption.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries));
        if (qToks.Count == 0) return 0;
        return Math.Round((double)qToks.Count(t => cToks.Contains(t)) / qToks.Count, 4);
    }
}
