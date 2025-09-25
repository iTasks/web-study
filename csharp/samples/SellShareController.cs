using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SellShareController : ControllerBase
    {
        private readonly ILogger<SellShareController> logger;
        private readonly Service.IStockClient service;

        public SellShareController(ILogger<SellShareController> logger)
        {
            this.logger = logger;
            service = Service.ServiceLoader.Instance();
        }


        [HttpPost]
        public StockInfo SellShare(StockInfo info)
        {
            logger.Log(LogLevel.Information, "Sell Share.....");
            return service.SubmitSellRequest(service.GetSessionId(), info);
        }
    }
}
