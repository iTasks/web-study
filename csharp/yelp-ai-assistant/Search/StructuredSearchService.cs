using System.Collections.Concurrent;
using YelpAiAssistant.Models;

namespace YelpAiAssistant.Search;

public class StructuredSearchService
{
    private readonly ConcurrentDictionary<string, BusinessData> _store = new();

    public void AddBusiness(BusinessData biz) => _store[biz.BusinessId] = biz;

    public IEnumerable<StructuredSearchResult> Search(string query, string businessId)
    {
        if (!_store.TryGetValue(businessId, out var biz)) yield break;
        var q = query.ToLowerInvariant();
        var matched = new List<string>();
        if (ContainsAny(q, "open", "close", "hour", "time")) matched.Add("hours");
        foreach (var key in biz.Amenities.Keys)
        {
            var label = key.Replace("_", " ");
            if (q.Contains(label) || q.Contains(key)) matched.Add("amenities." + key);
        }
        if (ContainsAny(q, "address", "location", "where", "phone")) matched.Add("address");
        yield return new StructuredSearchResult(biz, matched, matched.Count > 0 ? 1.0 : 0.5);
    }

    private static bool ContainsAny(string s, params string[] subs) => subs.Any(s.Contains);
}
