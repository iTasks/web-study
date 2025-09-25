using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace RestFixClient.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RejectShareController : ControllerBase
    {
        private readonly ILogger<RejectShareController> logger;
        private readonly Service.IStockClient service;

        public RejectShareController(ILogger<RejectShareController> logger)
        {
            this.logger = logger;
            service = Service.ServiceLoader.Instance();
        }


        [HttpPost]
        public StockInfo RejectShareTrx(StockInfo info) {
            logger.Log(LogLevel.Information, "Reject Share.....");
            return service.CancelRequest(service.GetSessionId(), info);
        
        }
        //[HttpGet]
        //public StockInfo GetRejectShareTrxStatus(StockInfo info) { return info; }
    }
}
