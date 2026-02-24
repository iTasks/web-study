using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using YelpAiAssistant.Models;

namespace YelpAiAssistant.Cache;

public class QueryCache
{
    private const int MaxSize = 10_000;
    private const int TtlSeconds = 300;

    private record Entry(QueryResponse Value, DateTimeOffset ExpiresAt);

    private readonly Dictionary<string, LinkedListNode<(string Key, Entry Entry)>> _index = new();
    private readonly LinkedList<(string Key, Entry Entry)> _order = new();
    private readonly object _lock = new();

    public bool TryGet(string businessId, string query, out QueryResponse? response)
    {
        lock (_lock)
        {
            var key = MakeKey(businessId, query);
            if (_index.TryGetValue(key, out var node))
            {
                if (DateTimeOffset.UtcNow < node.Value.Entry.ExpiresAt)
                {
                    _order.Remove(node);
                    _order.AddFirst(node);
                    response = node.Value.Entry.Value;
                    return true;
                }
                _order.Remove(node);
                _index.Remove(key);
            }
            response = null;
            return false;
        }
    }

    public void Set(string businessId, string query, QueryResponse response)
    {
        lock (_lock)
        {
            var key = MakeKey(businessId, query);
            if (_index.TryGetValue(key, out var existing)) { _order.Remove(existing); _index.Remove(key); }
            var entry = new Entry(response, DateTimeOffset.UtcNow.AddSeconds(TtlSeconds));
            var node = _order.AddFirst((key, entry));
            _index[key] = node;
            while (_order.Count > MaxSize && _order.Last is { } last)
            {
                _index.Remove(last.Value.Key);
                _order.RemoveLast();
            }
        }
    }

    public int Size { get { lock (_lock) return _index.Count; } }

    private static string MakeKey(string businessId, string query)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(businessId + ":" + query));
        return Convert.ToHexString(bytes[..8]).ToLowerInvariant();
    }
}
