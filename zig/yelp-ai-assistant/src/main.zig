//! Yelp-Style AI Assistant — Zig implementation
//!
//! A single-file HTTP server that classifies natural-language queries
//! about a business (intent detection), routes them to in-memory search
//! services, and returns a mock-RAG answer.
//!
//! Endpoints:
//!   POST /assistant/query
//!   GET  /health
//!   GET  /health/detailed
//!
//! Build & run:
//!   zig build run
//!   curl -X POST http://localhost:8080/assistant/query \
//!     -H "Content-Type: application/json" \
//!     -d '{"query":"Does it have wifi?","business_id":"12345"}'

const std = @import("std");

// ─────────────────────────────────────────────────────────────────────────────
// Domain types
// ─────────────────────────────────────────────────────────────────────────────

const QueryIntent = enum {
    operational,
    amenity,
    quality,
    photo,
    unknown,

    pub fn toString(self: QueryIntent) []const u8 {
        return switch (self) {
            .operational => "operational",
            .amenity => "amenity",
            .quality => "quality",
            .photo => "photo",
            .unknown => "unknown",
        };
    }
};

const BusinessHours = struct {
    day: []const u8,
    open_time: []const u8,
    close_time: []const u8,
    is_closed: bool = false,
};

const Amenity = struct {
    key: []const u8,
    value: bool,
};

const BusinessData = struct {
    business_id: []const u8,
    name: []const u8,
    address: []const u8,
    phone: []const u8,
    price_range: []const u8,
    rating: f32,
    review_count: u32,
    hours: []const BusinessHours,
    amenities: []const Amenity,
    categories: []const []const u8,
};

const Review = struct {
    review_id: []const u8,
    business_id: []const u8,
    rating: f32,
    text: []const u8,
};

const Photo = struct {
    photo_id: []const u8,
    business_id: []const u8,
    url: []const u8,
    caption: []const u8,
};

// ─────────────────────────────────────────────────────────────────────────────
// Cache
// ─────────────────────────────────────────────────────────────────────────────

const CACHE_SLOTS = 16;
const CACHE_RESPONSE_SIZE = 4096;

const CacheEntry = struct {
    key_hash: u64 = 0,
    response: [CACHE_RESPONSE_SIZE]u8 = undefined,
    response_len: usize = 0,
    timestamp: i64 = 0,
    valid: bool = false,
};

const SimpleCache = struct {
    entries: [CACHE_SLOTS]CacheEntry = [_]CacheEntry{.{}} ** CACHE_SLOTS,
    mutex: std.Thread.Mutex = .{},

    /// Returns index of hit, or null on miss.
    pub fn get(self: *SimpleCache, key_hash: u64, out: []u8) ?usize {
        self.mutex.lock();
        defer self.mutex.unlock();
        for (&self.entries) |*e| {
            if (e.valid and e.key_hash == key_hash) {
                const len = @min(e.response_len, out.len);
                @memcpy(out[0..len], e.response[0..len]);
                return len;
            }
        }
        return null;
    }

    /// Inserts into the cache, evicting the oldest slot if full.
    pub fn put(self: *SimpleCache, key_hash: u64, response: []const u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        // Find empty slot, or find oldest
        var oldest_idx: usize = 0;
        var oldest_ts: i64 = std.math.maxInt(i64);
        for (&self.entries, 0..) |*e, i| {
            if (!e.valid) {
                oldest_idx = i;
                oldest_ts = 0;
                break;
            }
            if (e.timestamp < oldest_ts) {
                oldest_ts = e.timestamp;
                oldest_idx = i;
            }
        }

        var e = &self.entries[oldest_idx];
        e.key_hash = key_hash;
        e.timestamp = std.time.milliTimestamp();
        e.valid = true;
        const len = @min(response.len, CACHE_RESPONSE_SIZE);
        @memcpy(e.response[0..len], response[0..len]);
        e.response_len = len;
    }

    pub fn size(self: *SimpleCache) usize {
        self.mutex.lock();
        defer self.mutex.unlock();
        var count: usize = 0;
        for (self.entries) |e| {
            if (e.valid) count += 1;
        }
        return count;
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// Circuit breaker
// ─────────────────────────────────────────────────────────────────────────────

const CB_THRESHOLD: u32 = 5;

fn isCircuitOpen(failure_count: u32) bool {
    return failure_count >= CB_THRESHOLD;
}

// ─────────────────────────────────────────────────────────────────────────────
// App state (global singleton)
// ─────────────────────────────────────────────────────────────────────────────

const AppState = struct {
    business: BusinessData,
    reviews: [3]Review,
    photos: [2]Photo,
    cb_structured_failures: std.atomic.Value(u32),
    cb_review_failures: std.atomic.Value(u32),
    cache: SimpleCache,
};

var app_state: AppState = undefined;

// ─────────────────────────────────────────────────────────────────────────────
// Demo data (seeded at startup)
// ─────────────────────────────────────────────────────────────────────────────

const demo_hours = [_]BusinessHours{
    .{ .day = "Monday", .open_time = "09:00", .close_time = "22:00" },
    .{ .day = "Tuesday", .open_time = "09:00", .close_time = "22:00" },
    .{ .day = "Wednesday", .open_time = "09:00", .close_time = "22:00" },
    .{ .day = "Thursday", .open_time = "09:00", .close_time = "22:00" },
    .{ .day = "Friday", .open_time = "09:00", .close_time = "23:00" },
    .{ .day = "Saturday", .open_time = "10:00", .close_time = "23:00" },
    .{ .day = "Sunday", .open_time = "10:00", .close_time = "21:00" },
};

const demo_amenities = [_]Amenity{
    .{ .key = "heated_patio", .value = true },
    .{ .key = "parking", .value = false },
    .{ .key = "wifi", .value = true },
    .{ .key = "wheelchair_accessible", .value = true },
};

const demo_categories = [_][]const u8{ "American", "Farm-to-Table", "Outdoor Seating" };

fn seedDemoData() void {
    app_state.business = BusinessData{
        .business_id = "12345",
        .name = "The Rustic Table",
        .address = "123 Main St, New York, NY 10001",
        .phone = "+1-212-555-0100",
        .price_range = "$$",
        .rating = 4.3,
        .review_count = 3,
        .hours = &demo_hours,
        .amenities = &demo_amenities,
        .categories = &demo_categories,
    };

    app_state.reviews = [3]Review{
        .{
            .review_id = "r1",
            .business_id = "12345",
            .rating = 5.0,
            .text = "Amazing heated patio — perfect for winter evenings.",
        },
        .{
            .review_id = "r2",
            .business_id = "12345",
            .rating = 4.0,
            .text = "Lovely atmosphere for a date night.",
        },
        .{
            .review_id = "r3",
            .business_id = "12345",
            .rating = 4.0,
            .text = "Good for groups. Parking nearby is tricky.",
        },
    };

    app_state.photos = [2]Photo{
        .{
            .photo_id = "p1",
            .business_id = "12345",
            .url = "https://example.com/photos/p1.jpg",
            .caption = "Outdoor heated patio with string lights in winter",
        },
        .{
            .photo_id = "p2",
            .business_id = "12345",
            .url = "https://example.com/photos/p2.jpg",
            .caption = "Cozy interior with rustic wooden decor",
        },
    };

    app_state.cb_structured_failures = std.atomic.Value(u32).init(0);
    app_state.cb_review_failures = std.atomic.Value(u32).init(0);
    app_state.cache = SimpleCache{};
}

// ─────────────────────────────────────────────────────────────────────────────
// Intent classification
// ─────────────────────────────────────────────────────────────────────────────

/// Lowercase-copies query into buf (caller owns buf), then scans for keywords.
/// Returns the intent with the most keyword hits.
fn classifyIntent(query: []const u8, buf: []u8) QueryIntent {
    const len = @min(query.len, buf.len - 1);
    for (query[0..len], 0..) |c, i| {
        buf[i] = std.ascii.toLower(c);
    }
    const q = buf[0..len];

    const operational_kw = [_][]const u8{ "open", "close", "hours", "today", "right now", "what time" };
    const amenity_kw = [_][]const u8{ "patio", "parking", "wifi", "wi-fi", "heated", "have", "wheelchair", "accessible" };
    const quality_kw = [_][]const u8{ "good", "great", "review", "rating", "date", "food", "worth", "best", "recommend" };
    const photo_kw = [_][]const u8{ "photo", "picture", "show", "image", "look" };

    var scores = [4]u32{ 0, 0, 0, 0 }; // operational, amenity, quality, photo

    for (operational_kw) |kw| {
        if (std.mem.indexOf(u8, q, kw) != null) scores[0] += 1;
    }
    for (amenity_kw) |kw| {
        if (std.mem.indexOf(u8, q, kw) != null) scores[1] += 1;
    }
    for (quality_kw) |kw| {
        if (std.mem.indexOf(u8, q, kw) != null) scores[2] += 1;
    }
    for (photo_kw) |kw| {
        if (std.mem.indexOf(u8, q, kw) != null) scores[3] += 1;
    }

    var best_score: u32 = 0;
    var best_intent: QueryIntent = .unknown;
    const intents = [4]QueryIntent{ .operational, .amenity, .quality, .photo };
    for (scores, 0..) |s, i| {
        if (s > best_score) {
            best_score = s;
            best_intent = intents[i];
        }
    }
    return best_intent;
}

// ─────────────────────────────────────────────────────────────────────────────
// Search services
// ─────────────────────────────────────────────────────────────────────────────

const SearchResult = struct {
    found: bool,
    text: []const u8,
    confidence: f32,
    reviews_used: u32,
    photos_used: u32,
};

/// Structured search: returns hours / amenities from in-memory business data.
fn structuredSearch(intent: QueryIntent, query: []const u8, buf: []u8) SearchResult {
    const b = &app_state.business;
    _ = query;

    if (isCircuitOpen(app_state.cb_structured_failures.load(.acquire))) {
        return .{ .found = false, .text = "structured service unavailable", .confidence = 0.0, .reviews_used = 0, .photos_used = 0 };
    }

    switch (intent) {
        .operational => {
            var written: usize = 0;
            written += (std.fmt.bufPrint(buf[written..], "{s} is open during these hours: ", .{b.name}) catch "").len;
            for (b.hours) |h| {
                if (written >= buf.len - 32) break;
                const part = std.fmt.bufPrint(buf[written..], "{s} {s}-{s}; ", .{ h.day, h.open_time, h.close_time }) catch "";
                written += part.len;
            }
            return .{ .found = true, .text = buf[0..written], .confidence = 0.92, .reviews_used = 0, .photos_used = 0 };
        },
        .amenity => {
            var written: usize = 0;
            written += (std.fmt.bufPrint(buf[written..], "{s} amenities: ", .{b.name}) catch "").len;
            for (b.amenities) |a| {
                if (written >= buf.len - 64) break;
                const yn = if (a.value) "yes" else "no";
                const part = std.fmt.bufPrint(buf[written..], "{s}={s}; ", .{ a.key, yn }) catch "";
                written += part.len;
            }
            return .{ .found = true, .text = buf[0..written], .confidence = 0.90, .reviews_used = 0, .photos_used = 0 };
        },
        else => {
            const t = std.fmt.bufPrint(buf, "{s}: rating {d:.1}, {d} reviews, {s}", .{
                b.name, b.rating, b.review_count, b.price_range,
            }) catch "error";
            return .{ .found = true, .text = t, .confidence = 0.75, .reviews_used = 0, .photos_used = 0 };
        },
    }
}

/// Review search: simple word-overlap scoring.
fn reviewSearch(query: []const u8, low_buf: []u8, match_buf: []u8) SearchResult {
    if (isCircuitOpen(app_state.cb_review_failures.load(.acquire))) {
        return .{ .found = false, .text = "review service unavailable", .confidence = 0.0, .reviews_used = 0, .photos_used = 0 };
    }

    const qlen = @min(query.len, low_buf.len - 1);
    for (query[0..qlen], 0..) |c, i| {
        low_buf[i] = std.ascii.toLower(c);
    }
    const q = low_buf[0..qlen];

    var best_review: ?*const Review = null;
    var best_score: u32 = 0;

    // Split query into words and count overlaps with review text
    var it = std.mem.tokenizeScalar(u8, q, ' ');
    var query_words: [32][]const u8 = undefined;
    var qword_count: usize = 0;
    while (it.next()) |w| {
        if (qword_count < query_words.len) {
            query_words[qword_count] = w;
            qword_count += 1;
        }
    }

    for (&app_state.reviews) |*rev| {
        // lowercase review text into match_buf temporarily
        const rlen = @min(rev.text.len, match_buf.len - 1);
        for (rev.text[0..rlen], 0..) |c, i| {
            match_buf[i] = std.ascii.toLower(c);
        }
        const rt = match_buf[0..rlen];

        var score: u32 = 0;
        for (query_words[0..qword_count]) |w| {
            if (w.len > 2 and std.mem.indexOf(u8, rt, w) != null) {
                score += 1;
            }
        }
        if (score > best_score) {
            best_score = score;
            best_review = rev;
        }
    }

    if (best_review) |rev| {
        const t = std.fmt.bufPrint(match_buf, "{s}", .{rev.text}) catch "error";
        const conf: f32 = @as(f32, @floatFromInt(best_score)) * 0.15 + 0.55;
        return .{ .found = true, .text = t, .confidence = @min(conf, 0.95), .reviews_used = 1, .photos_used = 0 };
    }

    return .{ .found = false, .text = "no matching reviews", .confidence = 0.0, .reviews_used = 0, .photos_used = 0 };
}

/// Photo search: returns photo captions for the business.
fn photoSearch(match_buf: []u8) SearchResult {
    var written: usize = 0;
    var count: u32 = 0;
    for (&app_state.photos) |*p| {
        if (written >= match_buf.len - 128) break;
        const part = std.fmt.bufPrint(match_buf[written..], "[{s}] {s}; ", .{ p.url, p.caption }) catch "";
        written += part.len;
        count += 1;
    }
    return .{ .found = count > 0, .text = match_buf[0..written], .confidence = 0.80, .reviews_used = 0, .photos_used = count };
}

// ─────────────────────────────────────────────────────────────────────────────
// Orchestration + answer generation
// ─────────────────────────────────────────────────────────────────────────────

const QueryResponse = struct {
    answer: []const u8,
    confidence: f32,
    intent: QueryIntent,
    reviews_used: u32,
    photos_used: u32,
    structured_used: bool,
};

fn orchestrate(
    query: []const u8,
    intent: QueryIntent,
    arena: std.mem.Allocator,
) !QueryResponse {
    // Buffers for search services
    var s_buf: [1024]u8 = undefined;
    var r_buf1: [512]u8 = undefined;
    var r_buf2: [512]u8 = undefined;
    var p_buf: [1024]u8 = undefined;

    switch (intent) {
        .operational => {
            const sr = structuredSearch(intent, query, &s_buf);
            const answer = try buildOperationalAnswer(arena, sr);
            return .{
                .answer = answer,
                .confidence = sr.confidence,
                .intent = intent,
                .reviews_used = 0,
                .photos_used = 0,
                .structured_used = sr.found,
            };
        },
        .amenity => {
            const sr = structuredSearch(intent, query, &s_buf);
            const answer = try buildAmenityAnswer(arena, query, sr);
            return .{
                .answer = answer,
                .confidence = sr.confidence,
                .intent = intent,
                .reviews_used = 0,
                .photos_used = 0,
                .structured_used = sr.found,
            };
        },
        .quality => {
            const rr = reviewSearch(query, &r_buf1, &r_buf2);
            const sr = structuredSearch(intent, query, &s_buf);
            const confidence = if (rr.found) rr.confidence * 0.7 + sr.confidence * 0.3 else sr.confidence * 0.5;
            const answer = try buildQualityAnswer(arena, rr, sr);
            return .{
                .answer = answer,
                .confidence = confidence,
                .intent = intent,
                .reviews_used = rr.reviews_used,
                .photos_used = 0,
                .structured_used = sr.found,
            };
        },
        .photo => {
            const pr = photoSearch(&p_buf);
            const answer = try buildPhotoAnswer(arena, pr);
            return .{
                .answer = answer,
                .confidence = pr.confidence,
                .intent = intent,
                .reviews_used = 0,
                .photos_used = pr.photos_used,
                .structured_used = false,
            };
        },
        .unknown => {
            const sr = structuredSearch(.quality, query, &s_buf);
            const rr = reviewSearch(query, &r_buf1, &r_buf2);
            const answer = try std.fmt.allocPrint(arena,
                "Based on available information about {s}: {s}",
                .{ app_state.business.name, if (rr.found) rr.text else sr.text });
            return .{
                .answer = answer,
                .confidence = 0.45,
                .intent = intent,
                .reviews_used = rr.reviews_used,
                .photos_used = 0,
                .structured_used = sr.found,
            };
        },
    }
}

fn buildOperationalAnswer(arena: std.mem.Allocator, sr: SearchResult) ![]const u8 {
    if (!sr.found) {
        return std.fmt.allocPrint(arena, "I couldn't find hours information for {s}.", .{app_state.business.name});
    }
    return std.fmt.allocPrint(arena, "{s}", .{sr.text});
}

fn buildAmenityAnswer(arena: std.mem.Allocator, query: []const u8, sr: SearchResult) ![]const u8 {
    if (!sr.found) {
        return std.fmt.allocPrint(arena, "I couldn't find amenity information for {s}.", .{app_state.business.name});
    }
    // Try to give a specific answer based on what was asked
    const q_lower_buf = try arena.alloc(u8, query.len);
    for (query, 0..) |c, i| q_lower_buf[i] = std.ascii.toLower(c);
    const q = q_lower_buf;

    for (app_state.business.amenities) |a| {
        if (std.mem.indexOf(u8, q, a.key) != null or
            (std.mem.eql(u8, a.key, "wifi") and std.mem.indexOf(u8, q, "wi-fi") != null) or
            (std.mem.eql(u8, a.key, "wifi") and std.mem.indexOf(u8, q, "wifi") != null) or
            (std.mem.eql(u8, a.key, "heated_patio") and std.mem.indexOf(u8, q, "patio") != null) or
            (std.mem.eql(u8, a.key, "heated_patio") and std.mem.indexOf(u8, q, "heated") != null) or
            (std.mem.eql(u8, a.key, "wheelchair_accessible") and std.mem.indexOf(u8, q, "wheelchair") != null))
        {
            const yn = if (a.value) "Yes" else "No";
            const readable = switch (a.key[0]) {
                'w' => if (std.mem.eql(u8, a.key, "wifi")) "WiFi" else if (std.mem.eql(u8, a.key, "wheelchair_accessible")) "wheelchair access" else a.key,
                'h' => "a heated patio",
                'p' => "parking",
                else => a.key,
            };
            const verb = if (a.value) "has" else "does not have";
            return std.fmt.allocPrint(arena, "{s} {s} {s}. ({s})", .{ app_state.business.name, verb, readable, yn });
        }
    }
    return std.fmt.allocPrint(arena, "{s}", .{sr.text});
}

fn buildQualityAnswer(arena: std.mem.Allocator, rr: SearchResult, sr: SearchResult) ![]const u8 {
    _ = sr;
    if (rr.found) {
        return std.fmt.allocPrint(arena,
            "{s} (rated {d:.1}/5): \"{s}\"",
            .{ app_state.business.name, app_state.business.rating, rr.text });
    }
    return std.fmt.allocPrint(arena,
        "{s} has a rating of {d:.1}/5 with {d} reviews.",
        .{ app_state.business.name, app_state.business.rating, app_state.business.review_count });
}

fn buildPhotoAnswer(arena: std.mem.Allocator, pr: SearchResult) ![]const u8 {
    if (!pr.found) {
        return std.fmt.allocPrint(arena, "No photos available for {s}.", .{app_state.business.name});
    }
    return std.fmt.allocPrint(arena,
        "Here are {d} photo(s) for {s}: {s}",
        .{ pr.photos_used, app_state.business.name, pr.text });
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache key
// ─────────────────────────────────────────────────────────────────────────────

fn cacheKey(business_id: []const u8, query: []const u8) u64 {
    var h = std.hash.Wyhash.init(0);
    h.update(business_id);
    h.update("|");
    h.update(query);
    return h.final();
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON helpers — manual writer
// ─────────────────────────────────────────────────────────────────────────────

/// Escape a string for JSON: replaces \ " and control chars.
fn jsonEscape(writer: anytype, s: []const u8) !void {
    for (s) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            else => try writer.writeByte(c),
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP handlers
// ─────────────────────────────────────────────────────────────────────────────

fn writeHttpResponse(stream: std.net.Stream, status: []const u8, content_type: []const u8, body: []const u8) !void {
    var buf: [256]u8 = undefined;
    const header = try std.fmt.bufPrint(&buf,
        "HTTP/1.1 {s}\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
        .{ status, content_type, body.len });
    try stream.writeAll(header);
    try stream.writeAll(body);
}

fn handleHealth(stream: std.net.Stream) !void {
    const body =
        \\{"status":"healthy","service":"yelp-ai-assistant","version":"0.1.0"}
    ;
    try writeHttpResponse(stream, "200 OK", "application/json", body);
}

fn handleHealthDetailed(stream: std.net.Stream) !void {
    var buf: [1024]u8 = undefined;
    const cb_s = app_state.cb_structured_failures.load(.acquire);
    const cb_r = app_state.cb_review_failures.load(.acquire);
    const cache_size = app_state.cache.size();

    const body = try std.fmt.bufPrint(&buf,
        \\{{
        \\  "status": "healthy",
        \\  "service": "yelp-ai-assistant",
        \\  "version": "0.1.0",
        \\  "circuit_breakers": {{
        \\    "structured_search": {{"failures": {d}, "open": {}}},
        \\    "review_search": {{"failures": {d}, "open": {}}}
        \\  }},
        \\  "cache": {{"slots_used": {d}, "total_slots": {d}}},
        \\  "business_loaded": true
        \\}}
    , .{
        cb_s, isCircuitOpen(cb_s),
        cb_r, isCircuitOpen(cb_r),
        cache_size, CACHE_SLOTS,
    });
    try writeHttpResponse(stream, "200 OK", "application/json", body);
}

const QueryRequest = struct {
    query: []const u8,
    business_id: []const u8,
};

fn handleQuery(stream: std.net.Stream, body: []const u8, arena: std.mem.Allocator) !void {
    const t_start = std.time.milliTimestamp();

    // ── Parse request JSON ────────────────────────────────────────────────────
    const parsed = std.json.parseFromSlice(struct {
        query: []const u8 = "",
        business_id: []const u8 = "",
    }, arena, body, .{ .ignore_unknown_fields = true }) catch {
        try writeHttpResponse(stream, "400 Bad Request", "application/json",
            \\{"error":"Invalid JSON body"}
        );
        return;
    };
    defer parsed.deinit();

    const query = parsed.value.query;
    const business_id = parsed.value.business_id;

    if (query.len == 0) {
        try writeHttpResponse(stream, "400 Bad Request", "application/json",
            \\{"error":"Missing required field: query"}
        );
        return;
    }

    // ── Cache check ───────────────────────────────────────────────────────────
    const key = cacheKey(business_id, query);
    var cached_buf: [CACHE_RESPONSE_SIZE]u8 = undefined;
    if (app_state.cache.get(key, &cached_buf)) |cached_len| {
        try stream.writeAll("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nX-Cache: HIT\r\nConnection: close\r\n");
        var hdr_buf: [64]u8 = undefined;
        const hdr = try std.fmt.bufPrint(&hdr_buf, "Content-Length: {d}\r\n\r\n", .{cached_len});
        try stream.writeAll(hdr);
        try stream.writeAll(cached_buf[0..cached_len]);
        return;
    }

    // ── Intent classification ─────────────────────────────────────────────────
    var low_buf: [512]u8 = undefined;
    const intent = classifyIntent(query, &low_buf);

    // ── Orchestrate search + answer generation ────────────────────────────────
    const qr = try orchestrate(query, intent, arena);

    const t_end = std.time.milliTimestamp();
    const latency_ms: f64 = @as(f64, @floatFromInt(t_end - t_start));

    // ── Serialize response ────────────────────────────────────────────────────
    var resp_buf: [CACHE_RESPONSE_SIZE]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&resp_buf);
    const w = fbs.writer();
    try w.writeAll("{");
    try w.writeAll("\"answer\":\"");
    try jsonEscape(w, qr.answer);
    try w.writeAll("\",");
    try w.print("\"confidence\":{d:.2},", .{qr.confidence});
    try w.print("\"intent\":\"{s}\",", .{intent.toString()});
    try w.print("\"evidence\":{{\"structured\":{},\"reviews_used\":{d},\"photos_used\":{d}}},", .{
        qr.structured_used, qr.reviews_used, qr.photos_used,
    });
    try w.print("\"latency_ms\":{d:.1}", .{latency_ms});
    try w.writeAll("}");

    const resp_body = fbs.getWritten();

    // ── Cache store ───────────────────────────────────────────────────────────
    app_state.cache.put(key, resp_body);

    try writeHttpResponse(stream, "200 OK", "application/json", resp_body);
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP request parser
// ─────────────────────────────────────────────────────────────────────────────

const HttpMethod = enum { GET, POST, OTHER };

const ParsedRequest = struct {
    method: HttpMethod,
    path: []const u8,
    body: []const u8,
};

fn parseRequest(raw: []const u8) ?ParsedRequest {
    // First line: "METHOD /path HTTP/1.1"
    const crlf = "\r\n";
    const first_line_end = std.mem.indexOf(u8, raw, crlf) orelse return null;
    const first_line = raw[0..first_line_end];

    var it = std.mem.tokenizeScalar(u8, first_line, ' ');
    const method_str = it.next() orelse return null;
    const path = it.next() orelse return null;

    const method: HttpMethod = if (std.mem.eql(u8, method_str, "GET"))
        .GET
    else if (std.mem.eql(u8, method_str, "POST"))
        .POST
    else
        .OTHER;

    // Body starts after \r\n\r\n
    const header_end_marker = "\r\n\r\n";
    const body_start = if (std.mem.indexOf(u8, raw, header_end_marker)) |pos|
        pos + header_end_marker.len
    else
        raw.len;

    const body = if (body_start < raw.len) raw[body_start..] else "";

    return .{ .method = method, .path = path, .body = body };
}

// ─────────────────────────────────────────────────────────────────────────────
// Connection handler (runs in its own thread)
// ─────────────────────────────────────────────────────────────────────────────

const ConnArgs = struct {
    conn: std.net.Server.Connection,
};

fn handleConnection(args: ConnArgs) void {
    defer args.conn.stream.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const alloc = arena.allocator();

    // Read request (up to 64 KiB)
    const MAX_REQ = 65536;
    const buf = alloc.alloc(u8, MAX_REQ) catch return;
    const n = args.conn.stream.read(buf) catch return;
    if (n == 0) return;
    const raw = buf[0..n];

    const req = parseRequest(raw) orelse {
        _ = writeHttpResponse(args.conn.stream, "400 Bad Request", "text/plain", "Bad Request") catch {};
        return;
    };

    if (req.method == .GET and std.mem.eql(u8, req.path, "/health")) {
        handleHealth(args.conn.stream) catch {};
    } else if (req.method == .GET and std.mem.eql(u8, req.path, "/health/detailed")) {
        handleHealthDetailed(args.conn.stream) catch {};
    } else if (req.method == .POST and std.mem.eql(u8, req.path, "/assistant/query")) {
        handleQuery(args.conn.stream, req.body, alloc) catch {};
    } else {
        _ = writeHttpResponse(args.conn.stream, "404 Not Found", "application/json",
            \\{"error":"Not found"}
        ) catch {};
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

pub fn main() !void {
    seedDemoData();

    const port: u16 = 8080;
    const addr = try std.net.Address.parseIp("0.0.0.0", port);
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Yelp AI Assistant listening on http://0.0.0.0:{d}\n", .{port});
    std.debug.print("  POST /assistant/query\n", .{});
    std.debug.print("  GET  /health\n", .{});
    std.debug.print("  GET  /health/detailed\n", .{});
    std.debug.print("Business seeded: {s} (id={s})\n", .{
        app_state.business.name, app_state.business.business_id,
    });

    while (true) {
        const conn = server.accept() catch |err| {
            std.debug.print("accept error: {}\n", .{err});
            continue;
        };
        const thread = std.Thread.spawn(.{}, handleConnection, .{ConnArgs{ .conn = conn }}) catch |err| {
            std.debug.print("spawn error: {}\n", .{err});
            conn.stream.close();
            continue;
        };
        thread.detach();
    }
}
