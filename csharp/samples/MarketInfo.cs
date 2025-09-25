namespace RestFixClient
{
    public class MarketInfo
    {
        public DateTime Date { get; set; }

        public double price { get; set; }

        public int count { get; set; }

        public string? Symbol { get; set;}
        public char? Side { get; set; }
        public string? Summary { get; set; }
    }
}