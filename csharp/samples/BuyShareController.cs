using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BuyShareController : ControllerBase
    {
        private readonly ILogger<BuyShareController> logger;
        private readonly Service.IStockClient service;

        public BuyShareController(ILogger<BuyShareController> logger)
        {
            this.logger = logger;
            service = Service.ServiceLoader.Instance();
        }


        [HttpPost]
        public StockInfo BuyShare(StockInfo info)
        {
            logger.Log(LogLevel.Information, "Buy Share.....");
            return service.SubmitBuyRequest(service.GetSessionId(), info);
        }
        
    }
}
