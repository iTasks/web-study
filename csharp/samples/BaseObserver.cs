using QuickFix;

namespace RestFixClient.Controllers.Service
{
    public abstract class BaseObserver : QuickFix.MessageCracker
    {
        public string sessionId { get; set; }
        public Session? session;
        public static void SetResult(string key, Object value)
        {
            ServiceLoader.Push(key, value);

        }
        public static void ClearResult(string key)
        {
            ServiceLoader.Clear(key);
        }
        public static Object GetResult(string key)
        {
            return ServiceLoader.Pop(key);
        }

        #region application
        public void FromAdmin(Message message, SessionID sessionID)
        {
            Console.WriteLine("From Admin: " + message.ToString() + " session: " + sessionID);
            try
            {
                Crack(message, sessionID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("==Cracker exception==");
                Console.WriteLine(ex.ToString());
                SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), ex.Message);
            }
        }

        public void FromApp(Message message, SessionID sessionID)
        {
            Console.WriteLine("From App: " + message.ToString() + " session: " + sessionID);
            try
            {
                Crack(message, sessionID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("==Cracker exception==");
                Console.WriteLine(ex.ToString());
                SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), ex.Message);
            }
        }

        public void OnCreate(SessionID sessionID)
        {
            Console.WriteLine("Session created: " + sessionID);
            session = Session.LookupSession(sessionID);
            sessionId = session.SessionID.ToString();
        }

        public void OnLogon(SessionID sessionID)
        {
            Console.WriteLine("Login: " + sessionID);
        }

        public void ToAdmin(Message message, SessionID sessionID)
        {
            Console.WriteLine("To Admin: " + message.ToString() + " session: " + sessionID);

        }

        public void ToApp(Message message, SessionID sessionID)
        {
            Console.WriteLine("To App: " + message.ToString() + " session: " + sessionID);

        }
        #endregion

        #region MessageCracker handlers
        public void OnMessage(QuickFix.FIX44.ExecutionReport m, SessionID s)
        {
            Console.WriteLine("Received execution report: " + m);
            var info = new StockInfo();
            info.OrderId = m.OrderID.ToString();
            info.Status = "Success: " + m.OrdStatus;
            SetResult(m.ClOrdID.ToString(), info);
        }

        public void OnMessage(QuickFix.FIX44.OrderCancelReject m, SessionID s)
        {
            Console.WriteLine("Received order cancel reject: " + m);
            var info = new StockInfo();
            info.OrderId = m.OrderID.ToString();
            info.Status = "Failed: " + m.OrdStatus;
            info.Message = "Failed: " + m.ToString();
            SetResult(m.ClOrdID.ToString(), info);
        }
        public void OnMessage(QuickFix.FIX42.OrderCancelReject m, SessionID s)
        {
            Console.WriteLine("Received order cancel reject: " + m);
            var info = new StockInfo();
            info.OrderId = m.OrderID.ToString();
            info.Status = "Failed: " + m.OrdStatus;
            info.Message = "Failed: " + m.ToString();
            SetResult(m.ClOrdID.ToString(), info);
        }

        
        public void OnMessage(QuickFix.FIX42.ExecutionReport m, SessionID s)
        {
            Console.WriteLine("Received execution report: " + m);
            var info = new StockInfo();
            info.OrderId = m.OrderID.ToString();
            info.ClOrderId = m.ClOrdID.ToString();
            info.Status = "Success: " + m.OrdStatus;
            SetResult(m.ClOrdID.ToString(), info);
        }

        public void OnMessage(QuickFix.FIX42.MarketDataIncrementalRefresh m, SessionID s)
        {
            Console.WriteLine("Received execution report+ " + m);
            //todo: need market data mapping
            SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), m);
        }

        public void OnMessage(QuickFix.FIX42.MarketDataSnapshotFullRefresh m, SessionID s)
        {
            Console.WriteLine("Received execution report+ " + m);
            //todo: need market data mapping
            SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), m);
        }

        public void OnMessage(QuickFix.FIX42.MarketDataRequestReject m, SessionID s)
        {
            Console.WriteLine("Received execution report+ " + m);
            SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), "Failed: "+ m.ToString());
        }

        public void OnMessage(QuickFix.FIX42.BusinessMessageReject m, SessionID s)
        {
            Console.WriteLine("Received execution report+ " + m);
            SetResult((string)GetResult(ServiceLoader.MESSAGE_KEY), "Failed: " + m.ToString());
        }
        #endregion
    }
}