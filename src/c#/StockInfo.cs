using System.ComponentModel;

namespace RestFixClient
{
    public class StockInfo
    {
        [DefaultValue("AB")] public string? SecurityId { get; set; } = "AB";
        [DefaultValue("AB")] public string? CompanyOrPerson { get; set; } = "AB";
        [DefaultValue("AB")] public string? ClOrderId { get; set; } = "AB";
        [DefaultValue("AB")] public string? OrderId { get; set; } = string.Empty;
        [DefaultValue("")] public string? OriginalClOrderId { get; set; } = string.Empty;
        [DefaultValue("")] public string? OriginalOrderId { get; set; } = string.Empty;
        [DefaultValue("40")] public double? StockPrice { get; set; } = 40D;
        [DefaultValue("110")] public double? StockPriceLimit { get; set; } = 110D;
        [DefaultValue("120")] public double? StockPriceStop { get; set; } = 120D;
        [DefaultValue("40")] public double? StockVolume { get; set; } = 40D;
        [DefaultValue("0")] public double? MockVolume { get; set; } = 0D;
        [DefaultValue("0")] public double? MockPrice { get; set; } = 0D;

        [DefaultValue("IBM")] public string? Symbol { get; set; } = "IBM";

        [DefaultValue("1")] public char? Side { get; set; } = '1';

        [DefaultValue("1")] public char? ExcMode { get; set; } = '1';

        [DefaultValue("1")] public char? ExcTime { get; set; } = '1';

        [DefaultValue("")] public string? Message { get; set; } = "";

        [DefaultValue("")] public string? Status { get; set; } = "";

    }
}
