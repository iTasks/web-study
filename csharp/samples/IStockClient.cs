namespace RestFixClient.Controllers.Service
{
    public interface IStockClient
    {
        string? login(string username = "default", string password = "defaultpass");
        string? logout(string sessionId);
        IEnumerable<MarketInfo> GetMarketInfo(string? sessionId);
        IEnumerable<MarketInfo> GetMarketInfo(string? sessionId, StockInfo? stockInfo);
        StockInfo SubmitSellRequest(string? sessionId, StockInfo stockInfo);
        StockInfo SubmitBuyRequest(string? sessionId, StockInfo stockInfo);
        StockInfo CancelRequest(string? sessionId, StockInfo stockInfo);
        StockInfo CheckRequest(string? sessionId, StockInfo stockInfo);
        string? GetSessionId(string user = "default");
        StockInfo ReplaceShareRequest(string? sessionId, StockInfo stockInfo);
    }
}
