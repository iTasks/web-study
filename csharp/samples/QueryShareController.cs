using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class QueryShareController : ControllerBase
    {
        private readonly ILogger<QueryShareController> logger;
        private readonly Service.IStockClient service;

        public QueryShareController(ILogger<QueryShareController> logger)
        {
            this.logger = logger;
            service = Service.ServiceLoader.Instance();
        }

        [HttpGet]
        public StockInfo SearchShareStatus(string clOrderId, string? orderId, string? symbol, char? side) {
            logger.Log(LogLevel.Information, "Search Share.....");
            StockInfo info = new StockInfo();
            info.ClOrderId = clOrderId;
            info.OrderId = orderId;
            info.Symbol = symbol != null ? symbol : "IBM";
            info.Side = side;
            return service.CheckRequest(service.GetSessionId(), info);
        }
    }
}
