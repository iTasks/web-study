﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuickFix.FIX44;
using QuickFix.Fields;
using QuickFix;

namespace TestFixClient
{
    public class TestClient: QuickFix.MessageCracker, QuickFix.IApplication
    {
       Session _session;

        // This variable is a kludge for developer test purposes.  Don't do this on a production application.
        public IInitiator MyInitiator;
        private string userName;
        private string password;

        #region IApplication interface overrides

        public void OnCreate(SessionID sessionID)
        {
            _session = Session.LookupSession(sessionID);
            userName = "ECOFIXFCS01";
            password = "password";
        }

        public void OnLogon(SessionID sessionID) { Console.WriteLine("Logon - " + sessionID.ToString()); }
        public void OnLogout(SessionID sessionID) { Console.WriteLine("Logout - " + sessionID.ToString()); }

        public void FromAdmin(QuickFix.Message message, SessionID sessionID) { 
         Console.WriteLine("From Admin: "+ message.ToString());
        }
        public void ToAdmin(QuickFix.Message message, SessionID sessionID) { 
            Console.WriteLine("To Admin: "+ message.ToString());
            var msgType = message.Header.GetString(QuickFix.Fields.Tags.MsgType);

            if (QuickFix.Fields.MsgType.LOGON.Equals(msgType) && userName!=null)
            {
                message.Header.SetField(new QuickFix.Fields.Username(userName));
                message.Header.SetField(new QuickFix.Fields.Password(password));
            }
        }

        public void FromApp(QuickFix.Message message, SessionID sessionID)
        {
            Console.WriteLine("IN:  " + message.ToString());
            try
            {
                Crack(message, sessionID);
            }
            catch (Exception ex)
            {
                Console.WriteLine("==Cracker exception==");
                Console.WriteLine(ex.ToString());
                Console.WriteLine(ex.StackTrace);
            }
        }

        public void ToApp(QuickFix.Message message, SessionID sessionID)
        {
            try
            {
                bool possDupFlag = false;
                if (message.Header.IsSetField(QuickFix.Fields.Tags.PossDupFlag))
                {
                    possDupFlag = QuickFix.Fields.Converters.BoolConverter.Convert(
                        message.Header.GetString(QuickFix.Fields.Tags.PossDupFlag)); /// FIXME
                }
                if (possDupFlag)
                    throw new DoNotSend();
            }
            catch (FieldNotFoundException)
            { }

            Console.WriteLine();
            Console.WriteLine("OUT: " + message.ToString());
        }
        #endregion


        #region MessageCracker handlers
        public void OnMessage(QuickFix.FIX42.ExecutionReport m, SessionID s)
        {
            Console.WriteLine("Received execution report");
        }

        public void OnMessage(QuickFix.FIX42.OrderCancelReject m, SessionID s)
        {
            Console.WriteLine("Received order cancel reject");
        }
        #endregion

        public void TestCommand()
        {
            if (!_session.IsLoggedOn) { 
               Thread.Sleep(2000);
            }
            try
            {
                Console.WriteLine("Start giving command....");
                Console.WriteLine("Enter Order...");
                QueryEnterOrder();
                //Console.WriteLine("Enter second Order...");
                //QueryEnterOrder();
                //Console.WriteLine("Replace Order...");
                //QueryReplaceOrder();
                //Console.WriteLine("Enter third Order...");
                //QueryEnterOrder();
                //Console.WriteLine("Cancel Order...");
                //QueryCancelOrder();
                //QueryEnterOrder();
            } catch (System.Exception e)
            {
                Console.WriteLine("Message Not Sent: " + e.Message);
                Console.WriteLine("StackTrace: " + e.StackTrace);
            }
        }
        public void Run()
        {
            while (true)
            {
                try
                {
                    char action = QueryAction();
                    if (action == '1')
                        QueryEnterOrder();
                    else if (action == '2')
                        QueryCancelOrder();
                    else if (action == '3')
                        QueryReplaceOrder();
                    else if (action == '4')
                        QueryMarketDataRequest();
                    else if (action == 'g')
                    {
                        if (this.MyInitiator.IsStopped)
                        {
                            Console.WriteLine("Restarting initiator...");
                            this.MyInitiator.Start();
                        }
                        else
                            Console.WriteLine("Already started.");
                    }
                    else if (action == 'x')
                    {
                        if (this.MyInitiator.IsStopped)
                            Console.WriteLine("Already stopped.");
                        else
                        {
                            Console.WriteLine("Stopping initiator...");
                            this.MyInitiator.Stop();
                        }
                    }
                    else if (action == 'q' || action == 'Q')
                        break;
                }
                catch (System.Exception e)
                {
                    Console.WriteLine("Message Not Sent: " + e.Message);
                    Console.WriteLine("StackTrace: " + e.StackTrace);
                }
            }
            Console.WriteLine("Program shutdown.");
        }

        private void SendMessage(QuickFix.Message m)
        {
            if (_session != null)
                _session.Send(m);
            else
            {
                // This probably won't ever happen.
                Console.WriteLine("Can't send message: session not created.");
            }
        }

        private char QueryAction()
        {
            // Commands 'g' and 'x' are intentionally hidden.
            Console.Write("\n"
                + "1) Enter Order\n"
                + "2) Cancel Order\n"
                + "3) Replace Order\n"
                + "4) Market data test\n"
                + "Q) Quit\n"
                + "Action: "
            );

            HashSet<string> validActions = new HashSet<string>("1,2,3,4,q,Q,g,x".Split(','));

            string cmd = Console.ReadLine().Trim();
            if (cmd.Length != 1 || validActions.Contains(cmd) == false)
                throw new System.Exception("Invalid action");

            return cmd.ToCharArray()[0];
        }

        private void QueryEnterOrder()
        {
            Console.WriteLine("\nNewOrderSingle");

            QuickFix.FIX42.NewOrderSingle m = QueryNewOrderSingle42();

            if (m != null && QueryConfirm("Send order"))
            {
                m.Header.GetString(Tags.BeginString);

                SendMessage(m);
            }
        }

        private void QueryCancelOrder()
        {
            Console.WriteLine("\nOrderCancelRequest");

            QuickFix.FIX42.OrderCancelRequest m = QueryOrderCancelRequest42();

            if (m != null && QueryConfirm("Cancel order"))
                SendMessage(m);
        }

        private void QueryReplaceOrder()
        {
            Console.WriteLine("\nCancelReplaceRequest");

            QuickFix.FIX42.OrderCancelReplaceRequest m = QueryCancelReplaceRequest42();

            if (m != null && QueryConfirm("Send replace"))
                SendMessage(m);
        }

        private void QueryMarketDataRequest()
        {
            Console.WriteLine("\nMarketDataRequest");

            QuickFix.FIX42.MarketDataRequest m = QueryMarketDataRequest42();

            if (m != null && QueryConfirm("Send market data request"))
                SendMessage(m);
        }

        private bool QueryConfirm(string query)
        {
            Console.WriteLine();
            Console.WriteLine(query + "?: ");
            //string line = Console.ReadLine().Trim();
            string line = "Y";
            return (line[0].Equals('y') || line[0].Equals('Y'));
        }

        #region Message creation functions
        private QuickFix.FIX42.NewOrderSingle QueryNewOrderSingle42()
        {
            QuickFix.Fields.OrdType ordType = null;

            QuickFix.FIX42.NewOrderSingle newOrderSingle = new QuickFix.FIX42.NewOrderSingle(
                QueryClOrdID(),
                new QuickFix.Fields.HandlInst('3'),
                QuerySymbol(),
                QuerySide(),
                new TransactTime(DateTime.Now),
                ordType = QueryOrdType());

            newOrderSingle.Set(new HandlInst('1'));
            newOrderSingle.Set(QueryOrderQty());
            newOrderSingle.Set(QueryTimeInForce());
            if (ordType.getValue() == OrdType.LIMIT || ordType.getValue() == OrdType.STOP_LIMIT)
                newOrderSingle.Set(QueryPrice());
            if (ordType.getValue() == OrdType.STOP || ordType.getValue() == OrdType.STOP_LIMIT)
                newOrderSingle.Set(QueryStopPx());

            return newOrderSingle;
        }

        private QuickFix.FIX42.OrderCancelRequest QueryOrderCancelRequest42()
        {
            QuickFix.FIX42.OrderCancelRequest orderCancelRequest = new QuickFix.FIX42.OrderCancelRequest(
                QueryOrigClOrdID(),
                QueryClOrdID(),
                QuerySymbol(),
                QuerySide(),
                new TransactTime(DateTime.Now));

            orderCancelRequest.Set(QueryOrderQty());
            return orderCancelRequest;
        }

        private QuickFix.FIX42.OrderCancelReplaceRequest QueryCancelReplaceRequest42()
        {
            QuickFix.FIX42.OrderCancelReplaceRequest ocrr = new QuickFix.FIX42.OrderCancelReplaceRequest(
                QueryOrigClOrdID(),
                QueryClOrdID(),
                new QuickFix.Fields.HandlInst('3'),
                QuerySymbol(),
                QuerySide(),
                new TransactTime(DateTime.Now),
                QueryOrdType());

            ocrr.Set(new HandlInst('1'));
            if (QueryConfirm("New price"))
                ocrr.Set(QueryPrice());
            if (QueryConfirm("New quantity"))
                ocrr.Set(QueryOrderQty());

            return ocrr;
        }

        private QuickFix.FIX42.MarketDataRequest QueryMarketDataRequest42()
        {
            MDReqID mdReqID = new MDReqID("MARKETDATAID");
            SubscriptionRequestType subType = new SubscriptionRequestType(SubscriptionRequestType.SNAPSHOT);
            MarketDepth marketDepth = new MarketDepth(0);

            QuickFix.FIX42.MarketDataRequest.NoMDEntryTypesGroup marketDataEntryGroup = new QuickFix.FIX42.MarketDataRequest.NoMDEntryTypesGroup();
            marketDataEntryGroup.Set(new MDEntryType(MDEntryType.BID));

            QuickFix.FIX42.MarketDataRequest.NoRelatedSymGroup symbolGroup = new QuickFix.FIX42.MarketDataRequest.NoRelatedSymGroup();
            symbolGroup.Set(new Symbol("LNUX"));

            QuickFix.FIX42.MarketDataRequest message = new QuickFix.FIX42.MarketDataRequest(mdReqID, subType, marketDepth);
            message.AddGroup(marketDataEntryGroup);
            message.AddGroup(symbolGroup);

            return message;
        }
        #endregion

        #region field query private methods
        private ClOrdID QueryClOrdID()
        {
            Console.WriteLine();
            Console.Write("ClOrdID? ");
            //return new ClOrdID(Console.ReadLine().Trim());
            return new ClOrdID("ABCD123");
        }

        private OrigClOrdID QueryOrigClOrdID()
        {
            Console.WriteLine();
            Console.Write("OrigClOrdID? ");
            //return new OrigClOrdID(Console.ReadLine().Trim());
            return new OrigClOrdID("CDEF5678");
        }

        private Symbol QuerySymbol()
        {
            Console.WriteLine();
            Console.Write("Symbol? ");
            //return new Symbol(Console.ReadLine().Trim());
            return new Symbol("B");
        }

        private Side QuerySide()
        {
            Console.WriteLine();
            Console.WriteLine("1) Buy");
            Console.WriteLine("2) Sell");
            Console.WriteLine("3) Sell Short");
            Console.WriteLine("4) Sell Short Exempt");
            Console.WriteLine("5) Cross");
            Console.WriteLine("6) Cross Short");
            Console.WriteLine("7) Cross Short Exempt");
            Console.Write("Side? ");
            //string s = Console.ReadLine().Trim();
            string s = "1";

            char c = ' ';
            switch (s)
            {
                case "1": c = Side.BUY; break;
                case "2": c = Side.SELL; break;
                case "3": c = Side.SELL_SHORT; break;
                case "4": c = Side.SELL_SHORT_EXEMPT; break;
                case "5": c = Side.CROSS; break;
                case "6": c = Side.CROSS_SHORT; break;
                case "7": c = 'A'; break;
                default: throw new Exception("unsupported input");
            }
            return new Side(c);
        }

        private OrdType QueryOrdType()
        {
            Console.WriteLine();
            Console.WriteLine("1) Market");
            Console.WriteLine("2) Limit");
            Console.WriteLine("3) Stop");
            Console.WriteLine("4) Stop Limit");
            Console.Write("OrdType? ");
            //string s = Console.ReadLine().Trim();
            string s = "1";

            char c = ' ';
            switch (s)
            {
                case "1": c = OrdType.MARKET; break;
                case "2": c = OrdType.LIMIT; break;
                case "3": c = OrdType.STOP; break;
                case "4": c = OrdType.STOP_LIMIT; break;
                default: throw new Exception("unsupported input");
            }
            return new OrdType(c);
        }

        private OrderQty QueryOrderQty()
        {
            Console.WriteLine();
            Console.Write("OrderQty? ");
            //return new OrderQty(Convert.ToDecimal(Console.ReadLine().Trim()));
            return new OrderQty(Convert.ToDecimal("22.34"));
        }

        private TimeInForce QueryTimeInForce()
        {
            Console.WriteLine();
            Console.WriteLine("1) Day");
            Console.WriteLine("2) IOC");
            Console.WriteLine("3) OPG");
            Console.WriteLine("4) GTC");
            Console.WriteLine("5) GTX");
            Console.Write("TimeInForce? ");
            //string s = Console.ReadLine().Trim();
            string s = "3";

            char c = ' ';
            switch (s)
            {
                case "1": c = TimeInForce.DAY; break;
                case "2": c = TimeInForce.IMMEDIATE_OR_CANCEL; break;
                case "3": c = TimeInForce.AT_THE_OPENING; break;
                case "4": c = TimeInForce.GOOD_TILL_CANCEL; break;
                case "5": c = TimeInForce.GOOD_TILL_CROSSING; break;
                default: throw new Exception("unsupported input");
            }
            return new TimeInForce(c);
        }

        private Price QueryPrice()
        {
            Console.WriteLine();
            Console.Write("Price? ");
            //return new Price(Convert.ToDecimal(Console.ReadLine().Trim()));
            return new Price(Convert.ToDecimal("50.33"));

        }

        private StopPx QueryStopPx()
        {
            Console.WriteLine();
            Console.Write("StopPx? ");
            //return new StopPx(Convert.ToDecimal(Console.ReadLine().Trim()));
            return new StopPx(Convert.ToDecimal("100.33"));
        }

        #endregion
    }


}
