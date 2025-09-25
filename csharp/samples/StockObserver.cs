using QuickFix;

namespace RestFixClient.Controllers.Service
{
    public class StockObserver :  BaseObserver, QuickFix.IApplication
    {

        internal void CancelShareRequest(string? sessionId, StockInfo info)
        {
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, info.ClOrderId);
                var ordType = new QuickFix.Fields.OrdType(QuickFix.Fields.OrdType.MARKET);
                var message = new QuickFix.FIX42.OrderCancelRequest(
                    new QuickFix.Fields.OrigClOrdID(info.OriginalClOrderId),
                    new QuickFix.Fields.ClOrdID(info.ClOrderId),
                    new QuickFix.Fields.Symbol(info.Symbol),
                    '1'.Equals(info.Side) ? new QuickFix.Fields.Side(QuickFix.Fields.Side.BUY) :
                    new QuickFix.Fields.Side(QuickFix.Fields.Side.SELL),
                    new QuickFix.Fields.TransactTime(DateTime.Now));
                message.Set(new QuickFix.Fields.OrderQty(Convert.ToDecimal(info.StockVolume)));
                message.Set(new QuickFix.Fields.OrderQty(Convert.ToDecimal(info.StockPrice)));

                ClearResult(info.ClOrderId);
                message.Header.GetString(QuickFix.Fields.Tags.BeginString);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(info.ClOrderId, "Failed:"+ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }

        }

        public void OnLogout(SessionID sessionID)
        {
            Console.WriteLine("Logout: " + sessionID);
        }

        internal void GetMarketInfos(string? sessionId, StockInfo? info)
        {
            string ClKey = "MDR-" + DateTime.Now.Ticks;
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, ClKey);
                var mdReqID = new QuickFix.Fields.MDReqID(ClKey);
                var subType = new QuickFix.Fields.SubscriptionRequestType(QuickFix.Fields.SubscriptionRequestType.SNAPSHOT);
                var marketDepth = new QuickFix.Fields.MarketDepth(0);

                var marketDataEntryGroup = new QuickFix.FIX42.MarketDataRequest.NoMDEntryTypesGroup();
                marketDataEntryGroup.Set(new QuickFix.Fields.MDEntryType(QuickFix.Fields.MDEntryType.BID));

                var symbolGroup = new QuickFix.FIX42.MarketDataRequest.NoRelatedSymGroup();
                if (info?.Symbol != null)
                {
                    symbolGroup.Set(new QuickFix.Fields.Symbol(info.Symbol.Trim()));
                }
                else
                {
                    symbolGroup.Set(new QuickFix.Fields.Symbol("LNUX"));
                }

                var message = new QuickFix.FIX42.MarketDataRequest(mdReqID, subType, marketDepth);
                message.AddGroup(marketDataEntryGroup);
                message.AddGroup(symbolGroup);

                ClearResult(ClKey);
                //message.Header.GetString(QuickFix.Fields.Tags.BeginString);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(ClKey, "Failed: "+ ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }

        }

        internal void CheckShareRequest(string? sessionId, StockInfo info)
        {
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, info.ClOrderId);
                var message = new QuickFix.FIX42.OrderStatusRequest(
                    new QuickFix.Fields.ClOrdID(info.ClOrderId),
                    new QuickFix.Fields.Symbol(info.Symbol),
                    '1'.Equals(info.Side) ? new QuickFix.Fields.Side(QuickFix.Fields.Side.BUY) :
                    new QuickFix.Fields.Side(QuickFix.Fields.Side.SELL));

                ClearResult(info.ClOrderId);
                message.Header.GetString(QuickFix.Fields.Tags.BeginString);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(info.ClOrderId, "Failed:"+ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }
        }

        private void SendMessage(QuickFix.Message m)
        {
            if (session != null)
            {
                session.Send(m);
            }
            else
            {
                // This probably won't ever happen.
                Console.WriteLine("Can't send message: session not created.");
                SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), "Failed:");
            }
             Task.Delay(ServiceLoader.FETCH_STATUS_DELAY_MILLI);
        }

        internal void ReplaceShareRequest(string? sessionId, StockInfo info)
        {
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, info.ClOrderId);
                var ordType = new QuickFix.Fields.OrdType(QuickFix.Fields.OrdType.MARKET);

                var message = new QuickFix.FIX42.OrderCancelReplaceRequest(
                    new QuickFix.Fields.OrigClOrdID(info.OriginalClOrderId),
                    new QuickFix.Fields.ClOrdID(info.ClOrderId),
                    new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC),//todo: need to configure
                    new QuickFix.Fields.Symbol(info.Symbol),
                    '1'.Equals(info.Side) ? new QuickFix.Fields.Side(QuickFix.Fields.Side.BUY) :
                    new QuickFix.Fields.Side(QuickFix.Fields.Side.SELL),
                    new QuickFix.Fields.TransactTime(DateTime.Now),
                    ordType);

                message.Set(new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC));//todo: need to configure
                message.Set(new QuickFix.Fields.OrderQty(Convert.ToDecimal(info.StockPrice)));
                message.Set(new QuickFix.Fields.TimeInForce(QuickFix.Fields.TimeInForce.DAY));//todo: need to configure
                //todo: need to think
                if (ordType.getValue() == QuickFix.Fields.OrdType.LIMIT
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.Price(Convert.ToDecimal(info.StockPriceLimit)));
                if (ordType.getValue() == QuickFix.Fields.OrdType.STOP
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.StopPx(Convert.ToDecimal(info.StockPriceStop)));

                ClearResult(info.ClOrderId);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(info.ClOrderId, "Failed:" + ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }
        }

        internal void BuyShareRequest(string? sessionId, StockInfo info)
        {
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, info.ClOrderId);
                var ordType = new QuickFix.Fields.OrdType(QuickFix.Fields.OrdType.MARKET);

                var message = new QuickFix.FIX42.NewOrderSingle(
                    new QuickFix.Fields.ClOrdID(info.ClOrderId),
                    new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC),//todo: need to configure
                    new QuickFix.Fields.Symbol(info.Symbol),
                    new QuickFix.Fields.Side(QuickFix.Fields.Side.BUY),
                    new QuickFix.Fields.TransactTime(DateTime.Now),
                    ordType);

                message.Set(new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC));//todo: need to configure
                message.Set(new QuickFix.Fields.OrderQty(Convert.ToDecimal(info.StockPrice)));
                message.Set(new QuickFix.Fields.TimeInForce(QuickFix.Fields.TimeInForce.DAY));//todo: need to configure
                //todo: need to think
                if (ordType.getValue() == QuickFix.Fields.OrdType.LIMIT
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.Price(Convert.ToDecimal(info.StockPriceLimit)));
                if (ordType.getValue() == QuickFix.Fields.OrdType.STOP
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.StopPx(Convert.ToDecimal(info.StockPriceStop)));

                ClearResult(info.ClOrderId);
                message.Header.GetString(QuickFix.Fields.Tags.BeginString);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(info.ClOrderId, ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }
        }

        internal void SellShareRequest(string? sessionId, StockInfo info)
        {
            try
            {
                SetResult(ServiceLoader.MESSAGE_KEY, info.ClOrderId);
                var ordType = new QuickFix.Fields.OrdType(QuickFix.Fields.OrdType.MARKET);

                var message = new QuickFix.FIX42.NewOrderSingle(
                    new QuickFix.Fields.ClOrdID(info.ClOrderId),
                    new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC),//todo: need to configure
                    new QuickFix.Fields.Symbol(info.Symbol),
                    new QuickFix.Fields.Side(QuickFix.Fields.Side.SELL),
                    new QuickFix.Fields.TransactTime(DateTime.Now),
                    ordType);

                message.Set(new QuickFix.Fields.HandlInst(QuickFix.Fields.HandlInst.AUTOMATED_EXECUTION_ORDER_PUBLIC));//todo: need to configure
                message.Set(new QuickFix.Fields.OrderQty(Convert.ToDecimal(info.StockPrice)));
                message.Set(new QuickFix.Fields.TimeInForce(QuickFix.Fields.TimeInForce.DAY));//todo: need to configure
                //todo: need to think
                if (ordType.getValue() == QuickFix.Fields.OrdType.LIMIT
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.Price(Convert.ToDecimal(info.StockPriceLimit)));
                if (ordType.getValue() == QuickFix.Fields.OrdType.STOP
                    || ordType.getValue() == QuickFix.Fields.OrdType.STOP_LIMIT)
                    message.Set(new QuickFix.Fields.StopPx(Convert.ToDecimal(info.StockPriceStop)));

                ClearResult(info.ClOrderId);
                message.Header.GetString(QuickFix.Fields.Tags.BeginString);
                SendMessage(message);
            }
            catch (Exception ex)
            {
                SetResult(info.ClOrderId, ex.Message);
                Console.WriteLine("Exception in send: " + ex.ToString());
            }
        }

        

        
    }


}
