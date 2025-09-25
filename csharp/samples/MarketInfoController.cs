using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MarketInfoController : ControllerBase
    {
        private readonly ILogger<MarketInfoController> logger;
        private readonly Service.IStockClient service;

        public MarketInfoController(ILogger<MarketInfoController> logger)
        {
            this.logger = logger;
            service = service = Service.ServiceLoader.Instance();
        }
        [HttpGet, ActionName("GetAll")]
        public IEnumerable<MarketInfo> GetMarketName()
        {
            logger.Log(LogLevel.Information, "Market Snapshots.....");
            return service.GetMarketInfo(service?.GetSessionId());
        }

        [HttpPost, ActionName("PostOne")]
        public IEnumerable<MarketInfo> GetMarketDescription(string symbol) {
            logger.Log(LogLevel.Information, "Market Snapsots.....");
            var info = new StockInfo();
            info.Symbol = symbol;
            return service.GetMarketInfo(service.GetSessionId(), info);
        
        }

    }
}
