using System.Text.Json;
using System.Text.Json.Serialization;
using YelpAiAssistant.Cache;
using YelpAiAssistant.Intent;
using YelpAiAssistant.Models;
using YelpAiAssistant.Orchestration;
using YelpAiAssistant.Rag;
using YelpAiAssistant.Resilience;
using YelpAiAssistant.Routing;
using YelpAiAssistant.Search;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:8080");

// Register services
builder.Services.AddSingleton<StructuredSearchService>();
builder.Services.AddSingleton<ReviewVectorSearchService>();
builder.Services.AddSingleton<PhotoHybridRetrievalService>();
builder.Services.AddSingleton<IntentClassifier>();
builder.Services.AddSingleton<QueryRouter>();
builder.Services.AddSingleton<AnswerOrchestrator>();
builder.Services.AddSingleton<RagService>();
builder.Services.AddSingleton<QueryCache>();
builder.Services.AddSingleton<AppCircuitBreakers>();

builder.Services.ConfigureHttpJsonOptions(opts =>
{
    opts.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
    opts.SerializerOptions.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.SnakeCaseLower));
});

var app = builder.Build();

// Seed demo data
SeedDemoData(app.Services);

// X-Correlation-ID middleware
app.Use(async (ctx, next) =>
{
    var corr = ctx.Request.Headers["X-Correlation-ID"].FirstOrDefault()
               ?? Guid.NewGuid().ToString();
    ctx.Response.Headers["X-Correlation-ID"] = corr;
    await next();
});

// ─── Endpoints ────────────────────────────────────────────────────────────

app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    service = "yelp-ai-assistant",
    version = "1.0.0"
}));

app.MapGet("/health/detailed", (AppCircuitBreakers cbs, QueryCache cache) => Results.Ok(new
{
    status = "healthy",
    service = "yelp-ai-assistant",
    version = "1.0.0",
    circuit_breakers = new
    {
        structured_search    = cbs.Structured.StateName,
        review_vector_search = cbs.Review.StateName,
        photo_hybrid_search  = cbs.Photo.StateName
    },
    cache = new { l1_entries = cache.Size }
}));

app.MapPost("/assistant/query", async (
    QueryRequest req,
    IntentClassifier classifier,
    QueryRouter router,
    StructuredSearchService structSvc,
    ReviewVectorSearchService reviewSvc,
    PhotoHybridRetrievalService photoSvc,
    AnswerOrchestrator orchestrator,
    RagService ragSvc,
    QueryCache cache,
    AppCircuitBreakers cbs) =>
{
    if (string.IsNullOrWhiteSpace(req.Query) || string.IsNullOrWhiteSpace(req.BusinessId))
        return Results.BadRequest("query and business_id are required");

    var start = DateTime.UtcNow;

    // 1. Cache
    if (cache.TryGet(req.BusinessId, req.Query, out var cached))
        return Results.Ok(cached);

    // 2. Intent
    var intent = classifier.Classify(req.Query);

    // 3. Routing
    var decision = router.Decide(intent);

    // 4. Parallel search
    var structTask  = (decision.UseStructured   && !cbs.Structured.IsOpen)
        ? Task.Run(() => structSvc.Search(req.Query, req.BusinessId))
        : Task.FromResult(Array.Empty<StructuredSearchResult>() as IEnumerable<StructuredSearchResult>);

    var reviewTask  = (decision.UseReviewVector && !cbs.Review.IsOpen)
        ? Task.Run(() => reviewSvc.Search(req.Query, req.BusinessId, 5))
        : Task.FromResult(Array.Empty<ReviewSearchResult>() as IEnumerable<ReviewSearchResult>);

    var photoTask   = (decision.UsePhotoHybrid  && !cbs.Photo.IsOpen)
        ? Task.Run(() => photoSvc.Search(req.Query, req.BusinessId, 5))
        : Task.FromResult(Array.Empty<PhotoSearchResult>() as IEnumerable<PhotoSearchResult>);

    await Task.WhenAll(structTask, reviewTask, photoTask);

    // 5. Orchestrate
    var bundle = orchestrator.Orchestrate(
        structTask.Result.ToList(),
        reviewTask.Result.ToList(),
        photoTask.Result.ToList());

    // 6. Answer
    var answer = ragSvc.GenerateAnswer(req.Query, intent, bundle);
    var latency = (DateTime.UtcNow - start).TotalMilliseconds;

    var response = new QueryResponse(
        answer,
        bundle.FinalScore,
        intent,
        new EvidenceSummary(bundle.Business is not null, bundle.ReviewResults.Count, bundle.PhotoResults.Count),
        Math.Round(latency, 1));

    // 7. Cache + return
    cache.Set(req.BusinessId, req.Query, response);
    return Results.Ok(response);
});

app.Run();

// ─── Seed demo data ───────────────────────────────────────────────────────

static void SeedDemoData(IServiceProvider sp)
{
    var structured = sp.GetRequiredService<StructuredSearchService>();
    var reviews    = sp.GetRequiredService<ReviewVectorSearchService>();
    var photos     = sp.GetRequiredService<PhotoHybridRetrievalService>();

    var biz = new BusinessData(
        "12345", "The Rustic Table",
        "123 Main St, New York, NY 10001",
        "+1-212-555-0100", "$$",
        new[]
        {
            new BusinessHours("monday",    "09:00", "22:00"),
            new BusinessHours("tuesday",   "09:00", "22:00"),
            new BusinessHours("wednesday", "09:00", "22:00"),
            new BusinessHours("thursday",  "09:00", "22:00"),
            new BusinessHours("friday",    "09:00", "23:00"),
            new BusinessHours("saturday",  "10:00", "23:00"),
            new BusinessHours("sunday",    "10:00", "21:00"),
        },
        new Dictionary<string, bool>
        {
            ["heated_patio"]          = true,
            ["parking"]               = false,
            ["wifi"]                  = true,
            ["wheelchair_accessible"] = true,
        },
        new[] { "American", "Brunch", "Bar" },
        4.3, 215);

    structured.AddBusiness(biz);

    reviews.AddReview(new Review("r1", "12345", "u1", 5.0,
        "Amazing heated patio — perfect for winter evenings. Great cocktails too!"));
    reviews.AddReview(new Review("r2", "12345", "u2", 4.0,
        "Lovely atmosphere for a date night. The food was excellent."));
    reviews.AddReview(new Review("r3", "12345", "u3", 3.5,
        "Good for groups. Parking nearby is tricky on weekends."));

    photos.AddPhoto(new Photo("p1", "12345",
        "https://example.com/photos/rustic-patio-1.jpg",
        "Outdoor heated patio with string lights in winter"));
    photos.AddPhoto(new Photo("p2", "12345",
        "https://example.com/photos/rustic-interior.jpg",
        "Cozy interior with rustic wooden decor"));
}
