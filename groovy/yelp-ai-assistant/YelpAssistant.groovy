/**
 * YelpAssistant.groovy
 *
 * Yelp-Style AI Assistant — Groovy / Ratpack implementation
 * Mirrors: https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant
 *
 * Run:
 *   groovy YelpAssistant.groovy
 *
 * Endpoints:
 *   POST /assistant/query
 *   GET  /health
 *   GET  /health/detailed
 */

@Grab('io.ratpack:ratpack-groovy:1.9.0')
@Grab('org.slf4j:slf4j-simple:1.7.36')

import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import ratpack.groovy.Groovy
import ratpack.handling.Context
import ratpack.http.Status

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicLong
import java.util.regex.Pattern

// ─────────────────────────────────────────────────────────────────────────────
// Domain models (simple maps / inner classes)
// ─────────────────────────────────────────────────────────────────────────────

enum QueryIntent {
    OPERATIONAL('operational'),
    AMENITY    ('amenity'),
    QUALITY    ('quality'),
    PHOTO      ('photo'),
    UNKNOWN    ('unknown')

    final String value
    QueryIntent(String v) { this.value = v }
    String toString() { value }
}

// ─────────────────────────────────────────────────────────────────────────────
// Intent Classifier
// ─────────────────────────────────────────────────────────────────────────────

class IntentClassifier {

    private static final Map<QueryIntent, List<Pattern>> SIGNALS = [
        (QueryIntent.OPERATIONAL): compile(
            /\bopen\b/, /\bclosed?\b/, /\bhours?\b/, /\bclose[sd]?\b/,
            /\btoday\b/, /\bright\s+now\b/, /\bcurrently\b/, /\btonight\b/,
            /\bmorning\b/, /\bevening\b/,
            /\bmonday\b/, /\btuesday\b/, /\bwednesday\b/, /\bthursday\b/,
            /\bfriday\b/, /\bsaturday\b/, /\bsunday\b/
        ),
        (QueryIntent.AMENITY): compile(
            /\bpatio\b/, /\bheater[sd]?\b/, /\bheated\b/, /\bparking\b/,
            /\bwifi\b/, /\bwi-fi\b/, /\bwheelchair\b/, /\baccessible\b/,
            /\boutdoor\b/, /\bindoor\b/, /\bseating\b/, /\bhave\b/,
            /\bdo\s+they\b/, /\bdoes\s+it\b/, /\bamenitie[sd]?\b/
        ),
        (QueryIntent.QUALITY): compile(
            /\bgood\b/, /\bbad\b/, /\bgreat\b/, /\bworth\b/,
            /\breview[sd]?\b/, /\brating[sd]?\b/, /\bdate\b/, /\bromantic\b/,
            /\bfamily\b/, /\brecommend\b/, /\bfood\b/, /\bservice\b/,
            /\batmosphere\b/, /\bambiance\b/
        ),
        (QueryIntent.PHOTO): compile(
            /\bphoto[sd]?\b/, /\bpicture[sd]?\b/, /\bimage[sd]?\b/,
            /\bshow\s+me\b/, /\bvisual[sd]?\b/, /\bgallery\b/
        )
    ]

    private static final List<QueryIntent> PRIORITY = [
        QueryIntent.OPERATIONAL, QueryIntent.AMENITY, QueryIntent.PHOTO, QueryIntent.QUALITY
    ]

    QueryIntent classify(String query) {
        def q = query.toLowerCase()
        def best = QueryIntent.UNKNOWN
        int bestScore = 0
        PRIORITY.each { intent ->
            int score = SIGNALS[intent].count { it.matcher(q).find() }
            if (score > bestScore) { bestScore = score; best = intent }
        }
        best
    }

    private static List<Pattern> compile(Object... patterns) {
        patterns.collect { Pattern.compile(it.toString(), Pattern.CASE_INSENSITIVE) }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Query Router
// ─────────────────────────────────────────────────────────────────────────────

class QueryRouter {
    Map decide(QueryIntent intent) {
        switch (intent) {
            case QueryIntent.OPERATIONAL: return [useStructured: true,  useReview: false, usePhoto: false]
            case QueryIntent.AMENITY:     return [useStructured: true,  useReview: true,  usePhoto: true]
            case QueryIntent.QUALITY:     return [useStructured: false, useReview: true,  usePhoto: false]
            case QueryIntent.PHOTO:       return [useStructured: false, useReview: false, usePhoto: true]
            default:                      return [useStructured: true,  useReview: true,  usePhoto: false]
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Services
// ─────────────────────────────────────────────────────────────────────────────

class StructuredSearchService {
    private final Map<String, Map> store = new ConcurrentHashMap<>()

    void addBusiness(Map biz) { store[biz.business_id] = biz }

    List<Map> search(String query, String businessId) {
        def biz = store[businessId]
        if (!biz) return []
        def q = query.toLowerCase()
        def matched = []
        if (['open','close','hour','time'].any { q.contains(it) }) matched << 'hours'
        biz.amenities?.each { k, v ->
            def label = k.replace('_', ' ')
            if (q.contains(label) || q.contains(k)) matched << "amenities.${k}"
        }
        if (['address','location','where','phone'].any { q.contains(it) }) matched << 'address'
        [[business: biz, matched_fields: matched, score: matched ? 1.0 : 0.5]]
    }
}

class ReviewVectorSearchService {
    private final List<Map> reviews = new CopyOnWriteArrayList<>()

    void addReview(Map r) { reviews << r }

    List<Map> search(String query, String businessId, int topK = 5) {
        def qVec = embed(query)
        reviews
            .findAll { it.business_id == businessId }
            .collect { r -> [review: r, similarity_score: cosine(qVec, embed(r.text)).round(4)] }
            .sort { -it.similarity_score }
            .take(topK)
    }

    private static double[] embed(String text) {
        def tokens = text.toLowerCase().split(/\s+/)
        def vec = new double[16]
        tokens.each { tok ->
            tok.eachWithIndex { ch, i -> vec[i % 16] += ch as int / 1000.0 }
        }
        vec
    }

    private static double cosine(double[] a, double[] b) {
        double dot = 0, na = 0, nb = 0
        (0..<a.length).each { i -> dot += a[i]*b[i]; na += a[i]*a[i]; nb += b[i]*b[i] }
        (na == 0 || nb == 0) ? 0.0 : dot / (Math.sqrt(na) * Math.sqrt(nb))
    }
}

class PhotoHybridRetrievalService {
    private final List<Map> photos = new CopyOnWriteArrayList<>()

    void addPhoto(Map p) { photos << p }

    List<Map> search(String query, String businessId, int topK = 5) {
        photos
            .findAll { it.business_id == businessId }
            .collect { p ->
                def cap = captionScore(query, p.caption ?: '')
                [photo: p, caption_score: cap, image_similarity: cap,
                 combined_score: cap]
            }
            .sort { -it.combined_score }
            .take(topK)
    }

    private static double captionScore(String query, String caption) {
        if (!caption) return 0.0
        def qToks = query.toLowerCase().split(/\s+/).toSet()
        def cToks = caption.toLowerCase().split(/\s+/).toSet()
        if (!qToks) return 0.0
        (qToks.intersect(cToks).size() / (double) qToks.size()).round(4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Orchestrator
// ─────────────────────────────────────────────────────────────────────────────

class AnswerOrchestrator {
    Map orchestrate(List<Map> structured, List<Map> reviews, List<Map> photos) {
        def biz          = structured ? structured[0].business : null
        def structScore  = structured ? structured[0].score : 0.0
        def conflicts    = []

        if (biz) {
            biz.amenities?.each { k, v ->
                def label = k.replace('_', ' ')
                if (!v && reviews.any { it.review.text?.toLowerCase()?.contains(label) }) {
                    conflicts << "Canonical data: no ${label}. Some reviews mention '${label}' — treat as anecdotal."
                }
            }
        }

        def avgReview = reviews ? reviews.sum { it.similarity_score } / reviews.size() : 0.0
        def avgPhoto  = photos  ? photos.sum  { it.combined_score   } / photos.size()  : 0.0
        def finalScore = (0.4 * structScore + 0.3 * avgReview + 0.3 * avgPhoto).round(4)

        [business: biz, structured_score: structScore,
         review_results: reviews, photo_results: photos,
         final_score: finalScore, conflict_notes: conflicts]
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock RAG Service
// ─────────────────────────────────────────────────────────────────────────────

class RagService {
    String generateAnswer(String query, QueryIntent intent, Map bundle) {
        def biz = bundle.business
        switch (intent) {
            case QueryIntent.OPERATIONAL:
                if (biz?.hours) {
                    def parts = biz.hours.collect { h ->
                        h.is_closed ? "${h.day.capitalize()}: Closed"
                                    : "${h.day.capitalize()}: ${h.open_time}–${h.close_time}"
                    }
                    return "Business hours for ${biz.name}: ${parts.join('; ')}."
                }
                return 'Business hours are not available.'

            case QueryIntent.AMENITY:
                if (biz?.amenities) {
                    def q = query.toLowerCase()
                    for (def entry in biz.amenities) {
                        def label = entry.key.replace('_', ' ')
                        if (q.contains(label) || q.contains(entry.key)) {
                            def status = entry.value ? 'Yes' : 'No'
                            def ans = "${biz.name} — ${label}: ${status} (canonical)."
                            if (bundle.conflict_notes) ans += " Note: ${bundle.conflict_notes[0]}"
                            return ans
                        }
                    }
                }
                return 'Amenity information is not available in our records.'

            case QueryIntent.QUALITY:
                def rr = bundle.review_results
                if (rr) {
                    def avg = (rr.sum { it.review.rating } / rr.size()).round(1)
                    return "Based on ${rr.size()} relevant review(s), average rating: ${avg}/5."
                }
                return 'No relevant reviews found to assess quality.'

            case QueryIntent.PHOTO:
                def pr = bundle.photo_results
                if (pr) {
                    def captions = pr.take(3).collect { it.photo.caption }.findAll { it }
                    if (captions) return "Found ${pr.size()} photo(s): ${captions.join('; ')}"
                }
                return 'No matching photos found.'

            default:
                if (biz) return "${biz.name} is located at ${biz.address}. Rating: ${biz.rating}/5. Phone: ${biz.phone}."
                return 'I could not find a specific answer to your question.'
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// LRU Cache (bounded LinkedHashMap, TTL-backed)
// ─────────────────────────────────────────────────────────────────────────────

class QueryCache {
    private static final int MAX_SIZE = 10_000
    private static final long TTL_MS  = 5 * 60 * 1000L

    private final Map<String, Map> store = Collections.synchronizedMap(
        new LinkedHashMap<String, Map>(256, 0.75f, true) {
            @Override protected boolean removeEldestEntry(Map.Entry e) { size() > MAX_SIZE }
        }
    )

    private static String key(String businessId, String query) {
        def bytes = (businessId + ':' + query).getBytes('UTF-8')
        def md    = java.security.MessageDigest.getInstance('SHA-256')
        md.digest(bytes)[0..7].collect { String.format('%02x', it & 0xFF) }.join('')
    }

    Optional<Map> get(String businessId, String query) {
        def k = key(businessId, query)
        def entry = store[k]
        if (!entry) return Optional.empty()
        if (System.currentTimeMillis() > entry.expires_at) { store.remove(k); return Optional.empty() }
        Optional.of(entry.value)
    }

    void set(String businessId, String query, Map response) {
        store[key(businessId, query)] = [value: response, expires_at: System.currentTimeMillis() + TTL_MS]
    }

    int size() { store.size() }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circuit Breaker
// ─────────────────────────────────────────────────────────────────────────────

class CircuitBreaker {
    private final String name
    private final int failureThreshold
    private final long recoveryMs
    private final AtomicInteger failures = new AtomicInteger(0)
    private final AtomicLong lastFailureMs = new AtomicLong(0)
    private volatile String state = 'closed'  // closed | open | half_open

    CircuitBreaker(String name, int threshold = 5, long recoveryMs = 30_000) {
        this.name = name; this.failureThreshold = threshold; this.recoveryMs = recoveryMs
    }

    boolean isOpen() {
        if (state == 'open') {
            if (System.currentTimeMillis() - lastFailureMs.get() >= recoveryMs) { state = 'half_open'; return false }
            return true
        }
        false
    }

    void recordSuccess() { failures.set(0); state = 'closed' }
    void recordFailure() { lastFailureMs.set(System.currentTimeMillis()); if (failures.incrementAndGet() >= failureThreshold) state = 'open' }
    String getStateName() { state }
}

// ─────────────────────────────────────────────────────────────────────────────
// Application singleton state + demo data seed
// ─────────────────────────────────────────────────────────────────────────────

def structuredSvc = new StructuredSearchService()
def reviewSvc     = new ReviewVectorSearchService()
def photoSvc      = new PhotoHybridRetrievalService()
def classifier    = new IntentClassifier()
def router        = new QueryRouter()
def orchestrator  = new AnswerOrchestrator()
def ragSvc        = new RagService()
def cache         = new QueryCache()
def cbStruct      = new CircuitBreaker('structured_search')
def cbReview      = new CircuitBreaker('review_vector_search')
def cbPhoto       = new CircuitBreaker('photo_hybrid_search')

// Seed demo data
structuredSvc.addBusiness([
    business_id: '12345', name: 'The Rustic Table',
    address: '123 Main St, New York, NY 10001',
    phone: '+1-212-555-0100', price_range: '$$',
    hours: [
        [day: 'monday',    open_time: '09:00', close_time: '22:00', is_closed: false],
        [day: 'tuesday',   open_time: '09:00', close_time: '22:00', is_closed: false],
        [day: 'wednesday', open_time: '09:00', close_time: '22:00', is_closed: false],
        [day: 'thursday',  open_time: '09:00', close_time: '22:00', is_closed: false],
        [day: 'friday',    open_time: '09:00', close_time: '23:00', is_closed: false],
        [day: 'saturday',  open_time: '10:00', close_time: '23:00', is_closed: false],
        [day: 'sunday',    open_time: '10:00', close_time: '21:00', is_closed: false],
    ],
    amenities: [heated_patio: true, parking: false, wifi: true, wheelchair_accessible: true],
    categories: ['American', 'Brunch', 'Bar'],
    rating: 4.3, review_count: 215
])
reviewSvc.addReview([review_id: 'r1', business_id: '12345', user_id: 'u1', rating: 5.0,
    text: 'Amazing heated patio — perfect for winter evenings. Great cocktails too!'])
reviewSvc.addReview([review_id: 'r2', business_id: '12345', user_id: 'u2', rating: 4.0,
    text: 'Lovely atmosphere for a date night. The food was excellent.'])
reviewSvc.addReview([review_id: 'r3', business_id: '12345', user_id: 'u3', rating: 3.5,
    text: 'Good for groups. Parking nearby is tricky on weekends.'])
photoSvc.addPhoto([photo_id: 'p1', business_id: '12345',
    url: 'https://example.com/photos/rustic-patio-1.jpg',
    caption: 'Outdoor heated patio with string lights in winter'])
photoSvc.addPhoto([photo_id: 'p2', business_id: '12345',
    url: 'https://example.com/photos/rustic-interior.jpg',
    caption: 'Cozy interior with rustic wooden decor'])

// ─────────────────────────────────────────────────────────────────────────────
// Ratpack server
// ─────────────────────────────────────────────────────────────────────────────

Ratpack.start {
    serverConfig { port 5050 }

    handlers {

        // X-Correlation-ID middleware
        all { ctx ->
            def corr = ctx.request.headers.get('X-Correlation-ID') ?: UUID.randomUUID().toString()
            ctx.response.headers.set('X-Correlation-ID', corr)
            ctx.next()
        }

        // GET /health
        get('health') {
            response.headers.set('Content-Type', 'application/json')
            render JsonOutput.toJson([status: 'healthy', service: 'yelp-ai-assistant', version: '1.0.0'])
        }

        // GET /health/detailed
        get('health/detailed') {
            response.headers.set('Content-Type', 'application/json')
            render JsonOutput.toJson([
                status: 'healthy', service: 'yelp-ai-assistant', version: '1.0.0',
                circuit_breakers: [
                    structured_search:    cbStruct.stateName,
                    review_vector_search: cbReview.stateName,
                    photo_hybrid_search:  cbPhoto.stateName,
                ],
                cache: [l1_entries: cache.size()]
            ])
        }

        // POST /assistant/query
        post('assistant/query') { ctx ->
            ctx.request.body.then { body ->
                def slurper = new JsonSlurper()
                def req = slurper.parseText(body.text)
                def query      = req?.query?.toString()?.trim()
                def businessId = req?.business_id?.toString()?.trim()

                if (!query || !businessId) {
                    ctx.response.status(400)
                    ctx.response.headers.set('Content-Type', 'application/json')
                    ctx.render JsonOutput.toJson([error: 'query and business_id are required'])
                    return
                }

                long start = System.nanoTime()

                // 1. Cache
                def cached = cache.get(businessId, query)
                if (cached.isPresent()) {
                    ctx.response.headers.set('Content-Type', 'application/json')
                    ctx.render JsonOutput.toJson(cached.get())
                    return
                }

                // 2. Intent
                def intent   = classifier.classify(query)
                def decision = router.decide(intent)

                // 3. Parallel search (Groovy parallel using threads)
                def structResults = []
                def reviewResults = []
                def photoResults  = []

                def threads = []
                if (decision.useStructured && !cbStruct.isOpen()) {
                    threads << Thread.start {
                        structResults = structuredSvc.search(query, businessId)
                        cbStruct.recordSuccess()
                    }
                }
                if (decision.useReview && !cbReview.isOpen()) {
                    threads << Thread.start {
                        reviewResults = reviewSvc.search(query, businessId)
                        cbReview.recordSuccess()
                    }
                }
                if (decision.usePhoto && !cbPhoto.isOpen()) {
                    threads << Thread.start {
                        photoResults = photoSvc.search(query, businessId)
                        cbPhoto.recordSuccess()
                    }
                }
                threads*.join()

                // 4. Orchestrate
                def bundle = orchestrator.orchestrate(structResults, reviewResults, photoResults)

                // 5. Answer
                def answer    = ragSvc.generateAnswer(query, intent, bundle)
                def latencyMs = (System.nanoTime() - start) / 1_000_000.0

                def response = [
                    answer:     answer,
                    confidence: bundle.final_score,
                    intent:     intent.value,
                    evidence:   [
                        structured:   bundle.business != null,
                        reviews_used: bundle.review_results.size(),
                        photos_used:  bundle.photo_results.size()
                    ],
                    latency_ms: latencyMs.round(1)
                ]

                // 6. Cache + return
                cache.set(businessId, query, response)
                ctx.response.headers.set('Content-Type', 'application/json')
                ctx.render JsonOutput.toJson(response)
            }
        }
    }
}
