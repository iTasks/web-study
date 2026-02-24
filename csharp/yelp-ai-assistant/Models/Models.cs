namespace YelpAiAssistant.Models;

public enum QueryIntent { Operational, Amenity, Quality, Photo, Unknown }

public record BusinessHours(string Day, string OpenTime, string CloseTime, bool IsClosed = false);

public record BusinessData(
    string BusinessId,
    string Name,
    string Address,
    string Phone,
    string PriceRange,
    IReadOnlyList<BusinessHours> Hours,
    IReadOnlyDictionary<string, bool> Amenities,
    IReadOnlyList<string> Categories,
    double Rating,
    int ReviewCount);

public record Review(string ReviewId, string BusinessId, string UserId, double Rating, string Text);

public record Photo(string PhotoId, string BusinessId, string Url, string Caption);

public record StructuredSearchResult(BusinessData Business, List<string> MatchedFields, double Score);

public record ReviewSearchResult(Review Review, double SimilarityScore);

public record PhotoSearchResult(Photo Photo, double CaptionScore, double ImageSimilarity)
{
    public double CombinedScore => 0.5 * CaptionScore + 0.5 * ImageSimilarity;
}

public record QueryRequest(string Query, string BusinessId);

public record EvidenceSummary(bool Structured, int ReviewsUsed, int PhotosUsed);

public record QueryResponse(
    string Answer,
    double Confidence,
    QueryIntent Intent,
    EvidenceSummary Evidence,
    double LatencyMs);

public record RoutingDecision(
    QueryIntent Intent,
    bool UseStructured,
    bool UseReviewVector,
    bool UsePhotoHybrid);
