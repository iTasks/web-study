using QuickFix.Fields;

namespace RestFixClient.Controllers.Service
{
    public class StockClient : IStockClient
    {
        private QuickFix.SessionSettings? settings;
        private QuickFix.IMessageStoreFactory? store;
        private QuickFix.ILogFactory? logger;
        private QuickFix.IInitiator? initiator;
        private StockObserver? observer;
        public StockClient()
        {
            observer = new StockObserver();
            settings = new QuickFix.SessionSettings(Path.GetFullPath("Properties/stockclient.cfg"));
            logger = new QuickFix.FileLogFactory(settings);
            store = new QuickFix.FileStoreFactory(settings);
            initSession();
        }

        private void initSession()
        {
            if (initiator == null)
                initiator = new QuickFix.Transport.SocketInitiator(observer, store, settings, logger);
            if (initiator.IsStopped)
                initiator.Start();
        }

        private async void deinitSession()
        {
            //todo: some backup task
            await Task.Delay(ServiceLoader.EXIT_DELAY_MILLI);
        }

        private async void destroy()
        {
            initiator?.Stop();
            await Task.Delay(ServiceLoader.EXIT_DELAY_MILLI);
        }

        public StockInfo CancelRequest(string? sessionId, StockInfo stockInfo)
        {
            Object value = null;
            initSession();
            stockInfo.ClOrderId = GetGeneratedUID(stockInfo.ClOrderId);
            observer?.CancelShareRequest(sessionId, stockInfo);
            return FetchStockResult(stockInfo, ref value);
        }

        private static string GetGeneratedUID(string? prefix)
        {
            if(prefix?.Length >=20)
                return prefix;
            string guid = System.Guid.NewGuid().ToString().Replace("_", "");
            if (prefix != null)
                return prefix + guid;
            else
                return "Sys-" + guid;
        }
        public StockInfo CheckRequest(string? sessionId, StockInfo stockInfo)
        {
            Object value = null;
            initSession();
            stockInfo.ClOrderId = GetGeneratedUID(stockInfo.ClOrderId);
            observer?.CheckShareRequest(sessionId, stockInfo);
            return FetchStockResult(stockInfo, ref value);
        }

        public IEnumerable<MarketInfo> GetMarketInfo(string? sessionId)
        {
            Object value = null;
            initSession();
            observer?.GetMarketInfos(GetSessionId(), null);
            return GetMarketDataResult(ref value);
        }

        private IEnumerable<MarketInfo> GetMarketDataResult(ref object? value)
        {
            Task.Delay(ServiceLoader.FETCH_STATUS_DELAY_MILLI);
            string key = (string)BaseObserver.GetResult(ServiceLoader.MESSAGE_KEY);
            if (BaseObserver.GetResult(key) != null)
            {
                value = BaseObserver.GetResult(key);
            }
            deinitSession();
            if (value != null)
            {
                var info = new MarketInfo();
                info.Summary = value.ToString();
                var list = new List<MarketInfo>();
                list.Add(info);
                return list;
            }
            return new List<MarketInfo>();
        }

        public IEnumerable<MarketInfo> GetMarketInfo(string? sessionId, StockInfo? stockInfo)
        {
            Object value = null;
            initSession();
            observer?.GetMarketInfos(GetSessionId(), stockInfo);
            return GetMarketDataResult(ref value);
        }

        public string? GetSessionId(string user = "default")
        {
            initSession();
            return observer?.sessionId;
        }

        public StockInfo ReplaceShareRequest(string? sessionId, StockInfo stockInfo)
        {
            Object value = null;
            initSession();
            stockInfo.ClOrderId = GetGeneratedUID(stockInfo.ClOrderId);
            observer?.ReplaceShareRequest(sessionId, stockInfo);
            return FetchStockResult(stockInfo, ref value);
        }

        public string? login(string username = "default", string password = "defaultpass")
        {
            //TODO: Need to fech from config and init session???
            throw new NotImplementedException();
        }

        public string? logout(string sessionId)
        {
            //TODO: Need to execute before leaving operation by schedulers???
            throw new NotImplementedException();
        }

        public StockInfo SubmitBuyRequest(string? sessionId, StockInfo stockInfo)
        {
            Object value = null;
            initSession();
            stockInfo.ClOrderId = GetGeneratedUID(stockInfo.ClOrderId);
            observer?.BuyShareRequest(sessionId, stockInfo);
            return FetchStockResult(stockInfo, ref value);
        }

        public StockInfo SubmitSellRequest(string? sessionId, StockInfo stockInfo)
        {
            Object value = null;
            initSession();
            stockInfo.ClOrderId = GetGeneratedUID(stockInfo.ClOrderId);
            observer?.SellShareRequest(sessionId, stockInfo);
            return FetchStockResult(stockInfo, ref value);
        }

        private StockInfo FetchStockResult(StockInfo stockInfo, ref object? value)
        {
            //Task.Delay(ServiceLoader.FETCH_STATUS_DELAY_MILLI);
            Thread.Sleep(ServiceLoader.FETCH_STATUS_DELAY_MILLI);
            if (BaseObserver.GetResult(stockInfo.ClOrderId) != null)
            {
                value = BaseObserver.GetResult(stockInfo.ClOrderId);
            }
            deinitSession();
            if (value != null)
            {
                if (typeof(StockInfo).IsAssignableFrom(value.GetType()))
                {
                    var rs = (StockInfo)value;
                    stockInfo.Message = rs.Message;
                    stockInfo.Status = rs.Status;
                    stockInfo.ClOrderId = rs.ClOrderId;
                    stockInfo.OrderId = rs.OrderId;
                    stockInfo.OriginalOrderId = rs.OriginalOrderId;
                    stockInfo.OriginalClOrderId = rs.OriginalClOrderId;
                }
                else
                {
                    stockInfo.Message = "Failed Execution";
                    stockInfo.Status = "Error";
                }

            }
            return stockInfo;
        }
    }
}
