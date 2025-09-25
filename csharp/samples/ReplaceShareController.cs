using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReplaceShareController : ControllerBase
    {
        private readonly ILogger<ReplaceShareController> logger;
        private readonly Service.IStockClient service;

        public ReplaceShareController(ILogger<ReplaceShareController> logger)
        {
            this.logger = logger;
            service = Service.ServiceLoader.Instance();
        }

        [HttpPost]
        public StockInfo ReplaceShareTrx(StockInfo stockInfo)
        {
            logger.Log(LogLevel.Information, "Replace Share.....");
            return service.ReplaceShareRequest(service.GetSessionId(), stockInfo);
        }
    }
}
