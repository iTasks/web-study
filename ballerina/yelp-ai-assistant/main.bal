// Yelp-Style AI Assistant — Ballerina implementation
//
// Mirrors the Python FastAPI reference at:
// https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant
//
// Endpoints:
//   POST /assistant/query
//   GET  /health
//   GET  /health/detailed
//
// Run:
//   bal run
//
// The service starts on port 9090.

import ballerina/http;
import ballerina/io;
import ballerina/time;

// ─────────────────────────────────────────────────────────────────────────────
// Domain types
// ─────────────────────────────────────────────────────────────────────────────

type QueryIntent "operational"|"amenity"|"quality"|"photo"|"unknown";

type BusinessHours record {|
    string day;
    string open_time;
    string close_time;
    boolean is_closed = false;
|};

type BusinessData record {|
    string business_id;
    string name;
    string address;
    string phone;
    string price_range;
    BusinessHours[] hours;
    map<boolean> amenities;
    string[] categories;
    float rating;
    int review_count;
|};

type Review record {|
    string review_id;
    string business_id;
    string user_id;
    float rating;
    string text;
|};

type Photo record {|
    string photo_id;
    string business_id;
    string url;
    string caption;
|};

type QueryRequest record {|
    string query;
    string business_id;
|};

type EvidenceSummary record {|
    boolean structured;
    int reviews_used;
    int photos_used;
|};

type QueryResponse record {|
    string answer;
    float confidence;
    string intent;
    EvidenceSummary evidence;
    float latency_ms;
|};

// ─────────────────────────────────────────────────────────────────────────────
// Intent Classifier
// ─────────────────────────────────────────────────────────────────────────────

// Keyword groups for each intent
final string[] OPERATIONAL_KW = ["open", "close", "hour", "today", "right now", "currently",
                                  "tonight", "morning", "evening", "monday", "tuesday", "wednesday",
                                  "thursday", "friday", "saturday", "sunday"];
final string[] AMENITY_KW     = ["patio", "heater", "heated", "parking", "wifi", "wi-fi",
                                  "wheelchair", "accessible", "outdoor", "indoor", "seating",
                                  "have", "do they", "does it", "amenities"];
final string[] QUALITY_KW     = ["good", "bad", "great", "worth", "review", "rating", "date",
                                  "romantic", "family", "recommend", "food", "service",
                                  "atmosphere", "ambiance"];
final string[] PHOTO_KW       = ["photo", "picture", "image", "show me", "visual", "gallery"];

function countMatches(string query, string[] keywords) returns int {
    string q = query.toLowerAscii();
    int count = 0;
    foreach string kw in keywords {
        if q.includes(kw) {
            count += 1;
        }
    }
    return count;
}

function classifyIntent(string query) returns QueryIntent {
    int opScore  = countMatches(query, OPERATIONAL_KW);
    int amScore  = countMatches(query, AMENITY_KW);
    int qualScore = countMatches(query, QUALITY_KW);
    int phScore  = countMatches(query, PHOTO_KW);

    // Tie-breaking: OPERATIONAL > AMENITY > PHOTO > QUALITY
    int maxScore = opScore;
    QueryIntent best = "operational";

    if amScore > maxScore   { maxScore = amScore;   best = "amenity"; }
    if phScore > maxScore   { maxScore = phScore;   best = "photo"; }
    if qualScore > maxScore { maxScore = qualScore; best = "quality"; }

    if maxScore == 0 { return "unknown"; }
    return best;
}

// ─────────────────────────────────────────────────────────────────────────────
// In-memory data stores (module-level variables)
// ─────────────────────────────────────────────────────────────────────────────

final map<BusinessData> businessStore = {};
final Review[] reviewStore = [];
final Photo[] photoStore = [];

// ─────────────────────────────────────────────────────────────────────────────
// Search helpers
// ─────────────────────────────────────────────────────────────────────────────

function searchStructured(string query, string businessId)
        returns record {| BusinessData biz; string[] matched; float score; |}? {
    if !businessStore.hasKey(businessId) { return (); }
    BusinessData biz = businessStore.get(businessId);
    string q = query.toLowerAscii();
    string[] matched = [];
    if q.includes("open") || q.includes("close") || q.includes("hour") || q.includes("time") {
        matched.push("hours");
    }
    foreach [string, boolean] [k, _] in biz.amenities.entries() {
        string label = re /_/.replaceAll(k, " ");
        if q.includes(label) || q.includes(k) {
            matched.push("amenities." + k);
        }
    }
    if q.includes("address") || q.includes("location") || q.includes("phone") {
        matched.push("address");
    }
    float score = matched.length() > 0 ? 1.0 : 0.5;
    return {biz: biz, matched: matched, score: score};
}

// Simple word-overlap similarity (no cosine needed for mock)
function wordOverlap(string a, string b) returns float {
    string[] aToks = re /\s+/.split(a.toLowerAscii());
    string[] bToks = re /\s+/.split(b.toLowerAscii());
    if aToks.length() == 0 { return 0.0; }
    int overlap = 0;
    foreach string tok in aToks {
        foreach string btok in bToks {
            if tok == btok { overlap += 1; break; }
        }
    }
    return <float>overlap / <float>aToks.length();
}

function searchReviews(string query, string businessId) returns Review[] {
    Review[] candidates = from Review r in reviewStore
        where r.business_id == businessId
        select r;
    // Sort by word-overlap score descending (simple selection sort for small N)
    int n = candidates.length();
    int[] indices = from int i in 0 ..< n select i;
    // Return top-3 by overlap
    Review[] sorted = [];
    float[] scores  = from Review r in candidates select wordOverlap(query, r.text);
    foreach int _ in 0 ..< (n < 5 ? n : 5) {
        int bestIdx = 0;
        float bestSc = -1.0;
        foreach int j in 0 ..< scores.length() {
            if scores[j] > bestSc { bestSc = scores[j]; bestIdx = j; }
        }
        if bestSc < 0.0 { break; }
        sorted.push(candidates[bestIdx]);
        scores[bestIdx] = -1.0;  // mark as used
    }
    return sorted;
}

function searchPhotos(string query, string businessId) returns Photo[] {
    return from Photo p in photoStore
        where p.business_id == businessId
        select p;
}

// ─────────────────────────────────────────────────────────────────────────────
// Answer generation (mock RAG)
// ─────────────────────────────────────────────────────────────────────────────

function generateAnswer(string query, QueryIntent intent,
        record {| BusinessData biz; string[] matched; float score; |}? structResult,
        Review[] reviews, Photo[] photos) returns string {

    if intent == "operational" {
        if structResult is record {| BusinessData biz; string[] matched; float score; |} {
            BusinessData biz = structResult.biz;
            if biz.hours.length() > 0 {
                string[] parts = from BusinessHours h in biz.hours
                    select h.is_closed
                        ? h.day.substring(0, 1).toUpperAscii() + h.day.substring(1) + ": Closed"
                        : h.day.substring(0, 1).toUpperAscii() + h.day.substring(1) + ": " + h.open_time + "–" + h.close_time;
                return "Business hours for " + biz.name + ": " + string:'join("; ", ...parts) + ".";
            }
        }
        return "Business hours are not available.";
    }

    if intent == "amenity" {
        if structResult is record {| BusinessData biz; string[] matched; float score; |} {
            BusinessData biz = structResult.biz;
            string q = query.toLowerAscii();
            foreach [string, boolean] [k, v] in biz.amenities.entries() {
                string label = re /_/.replaceAll(k, " ");
                if q.includes(label) || q.includes(k) {
                    string status = v ? "Yes" : "No";
                    return biz.name + " — " + label + ": " + status + " (canonical).";
                }
            }
        }
        return "Amenity information is not available in our records.";
    }

    if intent == "quality" {
        if reviews.length() > 0 {
            float total = 0.0;
            foreach Review r in reviews { total += r.rating; }
            float avg = total / <float>reviews.length();
            return "Based on " + reviews.length().toString() + " relevant review(s), average rating: "
                + avg.toString().substring(0, 3) + "/5.";
        }
        return "No relevant reviews found to assess quality.";
    }

    if intent == "photo" {
        if photos.length() > 0 {
            string[] captions = from Photo p in photos
                where p.caption != ""
                limit 3
                select p.caption;
            if captions.length() > 0 {
                return "Found " + photos.length().toString() + " photo(s): "
                    + string:'join("; ", ...captions);
            }
        }
        return "No matching photos found.";
    }

    // unknown
    if structResult is record {| BusinessData biz; string[] matched; float score; |} {
        BusinessData biz = structResult.biz;
        return biz.name + " is located at " + biz.address + ". Rating: "
            + biz.rating.toString() + "/5. Phone: " + biz.phone + ".";
    }
    return "I could not find a specific answer to your question.";
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple in-memory cache
// ─────────────────────────────────────────────────────────────────────────────

type CacheEntry record {|
    QueryResponse value;
    int expires_at;  // Unix seconds
|};

final map<CacheEntry> queryCache = {};
final int CACHE_TTL = 300;  // 5 minutes

function cacheKey(string businessId, string query) returns string {
    return businessId + ":" + query;
}

function cacheGet(string businessId, string query) returns QueryResponse? {
    string key = cacheKey(businessId, query);
    if !queryCache.hasKey(key) { return (); }
    CacheEntry entry = queryCache.get(key);
    int now = <int>(time:utcNow()[0]);
    if now > entry.expires_at { _ = queryCache.remove(key); return (); }
    return entry.value;
}

function cacheSet(string businessId, string query, QueryResponse response) {
    string key = cacheKey(businessId, query);
    int expiresAt = <int>(time:utcNow()[0]) + CACHE_TTL;
    queryCache[key] = {value: response, expires_at: expiresAt};
}

// ─────────────────────────────────────────────────────────────────────────────
// Circuit breaker state (simple counters)
// ─────────────────────────────────────────────────────────────────────────────

int cbStructFailures = 0;
int cbReviewFailures = 0;
int cbPhotoFailures  = 0;
final int CB_THRESHOLD = 5;

function cbState(int failures) returns string {
    return failures >= CB_THRESHOLD ? "open" : "closed";
}

// ─────────────────────────────────────────────────────────────────────────────
// Seed demo data
// ─────────────────────────────────────────────────────────────────────────────

function init() {
    io:println("🌱 Seeding demo data...");

    businessStore["12345"] = {
        business_id: "12345",
        name: "The Rustic Table",
        address: "123 Main St, New York, NY 10001",
        phone: "+1-212-555-0100",
        price_range: "$$",
        hours: [
            {day: "monday",    open_time: "09:00", close_time: "22:00"},
            {day: "tuesday",   open_time: "09:00", close_time: "22:00"},
            {day: "wednesday", open_time: "09:00", close_time: "22:00"},
            {day: "thursday",  open_time: "09:00", close_time: "22:00"},
            {day: "friday",    open_time: "09:00", close_time: "23:00"},
            {day: "saturday",  open_time: "10:00", close_time: "23:00"},
            {day: "sunday",    open_time: "10:00", close_time: "21:00"}
        ],
        amenities: {
            "heated_patio": true,
            "parking": false,
            "wifi": true,
            "wheelchair_accessible": true
        },
        categories: ["American", "Brunch", "Bar"],
        rating: 4.3,
        review_count: 215
    };

    reviewStore.push({review_id: "r1", business_id: "12345", user_id: "u1", rating: 5.0,
        text: "Amazing heated patio — perfect for winter evenings. Great cocktails too!"});
    reviewStore.push({review_id: "r2", business_id: "12345", user_id: "u2", rating: 4.0,
        text: "Lovely atmosphere for a date night. The food was excellent."});
    reviewStore.push({review_id: "r3", business_id: "12345", user_id: "u3", rating: 3.5,
        text: "Good for groups. Parking nearby is tricky on weekends."});

    photoStore.push({photo_id: "p1", business_id: "12345",
        url: "https://example.com/photos/rustic-patio-1.jpg",
        caption: "Outdoor heated patio with string lights in winter"});
    photoStore.push({photo_id: "p2", business_id: "12345",
        url: "https://example.com/photos/rustic-interior.jpg",
        caption: "Cozy interior with rustic wooden decor"});

    io:println("✅ Demo data seeded. Starting server on port 9090...");
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP Service
// ─────────────────────────────────────────────────────────────────────────────

service / on new http:Listener(9090) {

    resource function get health() returns json {
        return {
            "status": "healthy",
            "service": "yelp-ai-assistant",
            "version": "1.0.0"
        };
    }

    resource function get health/detailed() returns json {
        return {
            "status": "healthy",
            "service": "yelp-ai-assistant",
            "version": "1.0.0",
            "circuit_breakers": {
                "structured_search":    cbState(cbStructFailures),
                "review_vector_search": cbState(cbReviewFailures),
                "photo_hybrid_search":  cbState(cbPhotoFailures)
            },
            "cache": {
                "l1_entries": queryCache.length()
            }
        };
    }

    resource function post assistant/query(@http:Payload QueryRequest req)
            returns QueryResponse|http:BadRequest {

        string query      = req.query.trim();
        string businessId = req.business_id.trim();

        if query.length() == 0 || businessId.length() == 0 {
            return <http:BadRequest>{body: "query and business_id are required"};
        }

        // Record start time
        [int, decimal] startTime = time:utcNow();

        // 1. Cache check
        QueryResponse? cached = cacheGet(businessId, query);
        if cached is QueryResponse { return cached; }

        // 2. Intent classification
        QueryIntent intent = classifyIntent(query);

        // 3. Search (based on intent)
        var structResult = ();
        Review[] reviews = [];
        Photo[]  photos  = [];

        boolean useStructured = intent == "operational" || intent == "amenity" || intent == "unknown";
        boolean useReview     = intent == "amenity" || intent == "quality"     || intent == "unknown";
        boolean usePhoto      = intent == "amenity" || intent == "photo";

        if useStructured && cbStructFailures < CB_THRESHOLD {
            structResult = searchStructured(query, businessId);
        }
        if useReview && cbReviewFailures < CB_THRESHOLD {
            reviews = searchReviews(query, businessId);
        }
        if usePhoto && cbPhotoFailures < CB_THRESHOLD {
            photos = searchPhotos(query, businessId);
        }

        // 4. Score
        float structScore = structResult is record {| BusinessData biz; string[] matched; float score; |}
            ? structResult.score : 0.0;
        float avgReview = reviews.length() > 0
            ? (from Review r in reviews select r.rating).sum() / <float>reviews.length() / 5.0
            : 0.0;
        float avgPhoto = photos.length() > 0 ? 0.5 : 0.0;
        float confidence = <float>((<float>0.4 * structScore) + (<float>0.3 * avgReview) + (<float>0.3 * avgPhoto));

        // 5. Generate answer
        string answer = generateAnswer(query, intent, structResult, reviews, photos);

        // 6. Latency
        [int, decimal] endTime = time:utcNow();
        float latencyMs = <float>((endTime[0] - startTime[0]) * 1000 + (endTime[1] - startTime[1]) * 1000);

        QueryResponse response = {
            answer: answer,
            confidence: confidence,
            intent: intent,
            evidence: {
                structured: structResult is record {| BusinessData biz; string[] matched; float score; |},
                reviews_used: reviews.length(),
                photos_used: photos.length()
            },
            latency_ms: latencyMs
        };

        // 7. Cache and return
        cacheSet(businessId, query, response);
        return response;
    }
}
