// Yelp-Style AI Assistant — Go implementation
//
// Mirrors the Python FastAPI reference at:
// https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant
//
// Endpoints:
//
//	POST /assistant/query
//	GET  /health
//	GET  /health/detailed
//
// Run:
//
//	go run main.go
package main

import (
	"container/list"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"time"
)

// ---------------------------------------------------------------------------
// Domain models
// ---------------------------------------------------------------------------

type QueryIntent string

const (
	IntentOperational QueryIntent = "operational"
	IntentAmenity     QueryIntent = "amenity"
	IntentQuality     QueryIntent = "quality"
	IntentPhoto       QueryIntent = "photo"
	IntentUnknown     QueryIntent = "unknown"
)

type BusinessHours struct {
	Day       string `json:"day"`
	OpenTime  string `json:"open_time"`
	CloseTime string `json:"close_time"`
	IsClosed  bool   `json:"is_closed"`
}

type BusinessData struct {
	BusinessID  string            `json:"business_id"`
	Name        string            `json:"name"`
	Address     string            `json:"address"`
	Phone       string            `json:"phone"`
	PriceRange  string            `json:"price_range"`
	Hours       []BusinessHours   `json:"hours"`
	Amenities   map[string]bool   `json:"amenities"`
	Categories  []string          `json:"categories"`
	Rating      float64           `json:"rating"`
	ReviewCount int               `json:"review_count"`
}

type Review struct {
	ReviewID   string  `json:"review_id"`
	BusinessID string  `json:"business_id"`
	UserID     string  `json:"user_id"`
	Rating     float64 `json:"rating"`
	Text       string  `json:"text"`
}

type Photo struct {
	PhotoID    string `json:"photo_id"`
	BusinessID string `json:"business_id"`
	URL        string `json:"url"`
	Caption    string `json:"caption"`
}

type StructuredSearchResult struct {
	Business      BusinessData `json:"business"`
	MatchedFields []string     `json:"matched_fields"`
	Score         float64      `json:"score"`
}

type ReviewSearchResult struct {
	Review          Review  `json:"review"`
	SimilarityScore float64 `json:"similarity_score"`
}

type PhotoSearchResult struct {
	Photo          Photo   `json:"photo"`
	CaptionScore   float64 `json:"caption_score"`
	ImageSimilarity float64 `json:"image_similarity"`
}

func (p PhotoSearchResult) CombinedScore() float64 {
	return 0.5*p.CaptionScore + 0.5*p.ImageSimilarity
}

type QueryRequest struct {
	Query      string `json:"query"`
	BusinessID string `json:"business_id"`
}

type EvidenceSummary struct {
	Structured   bool `json:"structured"`
	ReviewsUsed  int  `json:"reviews_used"`
	PhotosUsed   int  `json:"photos_used"`
}

type QueryResponse struct {
	Answer     string          `json:"answer"`
	Confidence float64         `json:"confidence"`
	Intent     QueryIntent     `json:"intent"`
	Evidence   EvidenceSummary `json:"evidence"`
	LatencyMs  float64         `json:"latency_ms"`
}

type RoutingDecision struct {
	Intent           QueryIntent
	UseStructured    bool
	UseReviewVector  bool
	UsePhotoHybrid   bool
}

// ---------------------------------------------------------------------------
// Intent Classifier
// ---------------------------------------------------------------------------

var (
	operationalPatterns = compileAll([]string{
		`\bopen\b`, `\bclosed?\b`, `\bhours?\b`, `\bclose[sd]?\b`,
		`\btoday\b`, `\bright\s+now\b`, `\bcurrently\b`, `\btonight\b`,
		`\bmorning\b`, `\bevening\b`,
		`\bmonday\b`, `\btuesday\b`, `\bwednesday\b`, `\bthursday\b`,
		`\bfriday\b`, `\bsaturday\b`, `\bsunday\b`,
	})
	amenityPatterns = compileAll([]string{
		`\bpatio\b`, `\bheater[sd]?\b`, `\bheated\b`, `\bparking\b`,
		`\bwifi\b`, `\bwi-fi\b`, `\bwheelchair\b`, `\baccessible\b`,
		`\boutdoor\b`, `\bindoor\b`, `\bseating\b`, `\bhave\b`,
		`\bdo\s+they\b`, `\bdoes\s+it\b`, `\bamenitie[sd]?\b`,
	})
	qualityPatterns = compileAll([]string{
		`\bgood\b`, `\bbad\b`, `\bgreat\b`, `\bworth\b`,
		`\breview[sd]?\b`, `\brating[sd]?\b`, `\bdate\b`, `\bromantic\b`,
		`\bfamily\b`, `\brecommend\b`, `\bfood\b`, `\bservice\b`,
		`\batmosphere\b`, `\bambiance\b`,
	})
	photoPatterns = compileAll([]string{
		`\bphoto[sd]?\b`, `\bpicture[sd]?\b`, `\bimage[sd]?\b`,
		`\bshow\s+me\b`, `\bvisual[sd]?\b`, `\bgallery\b`,
	})
)

func compileAll(patterns []string) []*regexp.Regexp {
	compiled := make([]*regexp.Regexp, len(patterns))
	for i, p := range patterns {
		compiled[i] = regexp.MustCompile("(?i)" + p)
	}
	return compiled
}

func countMatches(query string, patterns []*regexp.Regexp) int {
	n := 0
	for _, p := range patterns {
		if p.MatchString(query) {
			n++
		}
	}
	return n
}

func classifyIntent(query string) QueryIntent {
	scores := map[QueryIntent]int{
		IntentOperational: countMatches(query, operationalPatterns),
		IntentAmenity:     countMatches(query, amenityPatterns),
		IntentQuality:     countMatches(query, qualityPatterns),
		IntentPhoto:       countMatches(query, photoPatterns),
	}
	// tie-breaking priority order
	priority := []QueryIntent{IntentOperational, IntentAmenity, IntentPhoto, IntentQuality}
	best := IntentUnknown
	bestScore := 0
	for _, intent := range priority {
		if scores[intent] > bestScore {
			bestScore = scores[intent]
			best = intent
		}
	}
	if bestScore == 0 {
		return IntentUnknown
	}
	return best
}

// ---------------------------------------------------------------------------
// Query Router
// ---------------------------------------------------------------------------

func routeIntent(intent QueryIntent) RoutingDecision {
	switch intent {
	case IntentOperational:
		return RoutingDecision{Intent: intent, UseStructured: true}
	case IntentAmenity:
		return RoutingDecision{Intent: intent, UseStructured: true, UseReviewVector: true, UsePhotoHybrid: true}
	case IntentQuality:
		return RoutingDecision{Intent: intent, UseReviewVector: true}
	case IntentPhoto:
		return RoutingDecision{Intent: intent, UsePhotoHybrid: true}
	default:
		return RoutingDecision{Intent: intent, UseStructured: true, UseReviewVector: true}
	}
}

// ---------------------------------------------------------------------------
// Search services
// ---------------------------------------------------------------------------

// StructuredSearchService

type StructuredSearchService struct {
	mu    sync.RWMutex
	store map[string]BusinessData
}

func NewStructuredSearchService() *StructuredSearchService {
	return &StructuredSearchService{store: make(map[string]BusinessData)}
}

func (s *StructuredSearchService) Add(b BusinessData) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.store[b.BusinessID] = b
}

func (s *StructuredSearchService) Search(query, businessID string) []StructuredSearchResult {
	s.mu.RLock()
	defer s.mu.RUnlock()
	biz, ok := s.store[businessID]
	if !ok {
		return nil
	}
	q := strings.ToLower(query)
	var matched []string
	if anyContains(q, "open", "close", "hour", "time") {
		matched = append(matched, "hours")
	}
	for k := range biz.Amenities {
		label := strings.ReplaceAll(k, "_", " ")
		if strings.Contains(q, label) || strings.Contains(q, k) {
			matched = append(matched, "amenities."+k)
		}
	}
	if anyContains(q, "address", "location", "where", "phone") {
		matched = append(matched, "address")
	}
	score := 1.0
	if len(matched) == 0 {
		score = 0.5
	}
	return []StructuredSearchResult{{Business: biz, MatchedFields: matched, Score: score}}
}

func anyContains(s string, subs ...string) bool {
	for _, sub := range subs {
		if strings.Contains(s, sub) {
			return true
		}
	}
	return false
}

// ReviewVectorSearchService

type ReviewVectorSearchService struct {
	mu      sync.RWMutex
	reviews []Review
}

func NewReviewVectorSearchService() *ReviewVectorSearchService {
	return &ReviewVectorSearchService{}
}

func (s *ReviewVectorSearchService) Add(r Review) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.reviews = append(s.reviews, r)
}

func bowEmbed(text string) []float64 {
	tokens := strings.Fields(strings.ToLower(text))
	dim := 16
	vec := make([]float64, dim)
	for _, tok := range tokens {
		for i, ch := range tok {
			vec[i%dim] += float64(ch) / 1000.0
		}
	}
	return vec
}

func cosine(a, b []float64) float64 {
	var dot, na, nb float64
	for i := range a {
		dot += a[i] * b[i]
		na += a[i] * a[i]
		nb += b[i] * b[i]
	}
	if na == 0 || nb == 0 {
		return 0
	}
	return dot / (math.Sqrt(na) * math.Sqrt(nb))
}

func (s *ReviewVectorSearchService) Search(query, businessID string, topK int) []ReviewSearchResult {
	s.mu.RLock()
	defer s.mu.RUnlock()
	qvec := bowEmbed(query)
	var results []ReviewSearchResult
	for _, r := range s.reviews {
		if r.BusinessID != businessID {
			continue
		}
		sim := cosine(qvec, bowEmbed(r.Text))
		results = append(results, ReviewSearchResult{Review: r, SimilarityScore: math.Round(sim*10000) / 10000})
	}
	// sort descending
	for i := 1; i < len(results); i++ {
		for j := i; j > 0 && results[j].SimilarityScore > results[j-1].SimilarityScore; j-- {
			results[j], results[j-1] = results[j-1], results[j]
		}
	}
	if topK < len(results) {
		return results[:topK]
	}
	return results
}

// PhotoHybridRetrievalService

type PhotoHybridRetrievalService struct {
	mu     sync.RWMutex
	photos []Photo
}

func NewPhotoHybridRetrievalService() *PhotoHybridRetrievalService {
	return &PhotoHybridRetrievalService{}
}

func (s *PhotoHybridRetrievalService) Add(p Photo) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.photos = append(s.photos, p)
}

func captionScore(query, caption string) float64 {
	if caption == "" {
		return 0
	}
	qTokens := make(map[string]bool)
	for _, t := range strings.Fields(strings.ToLower(query)) {
		qTokens[t] = true
	}
	cTokens := make(map[string]bool)
	for _, t := range strings.Fields(strings.ToLower(caption)) {
		cTokens[t] = true
	}
	if len(qTokens) == 0 {
		return 0
	}
	overlap := 0
	for t := range qTokens {
		if cTokens[t] {
			overlap++
		}
	}
	return math.Round(float64(overlap)/float64(len(qTokens))*10000) / 10000
}

func (s *PhotoHybridRetrievalService) Search(query, businessID string, topK int) []PhotoSearchResult {
	s.mu.RLock()
	defer s.mu.RUnlock()
	var results []PhotoSearchResult
	for _, p := range s.photos {
		if p.BusinessID != businessID {
			continue
		}
		cap := captionScore(query, p.Caption)
		results = append(results, PhotoSearchResult{Photo: p, CaptionScore: cap, ImageSimilarity: cap})
	}
	for i := 1; i < len(results); i++ {
		for j := i; j > 0 && results[j].CombinedScore() > results[j-1].CombinedScore(); j-- {
			results[j], results[j-1] = results[j-1], results[j]
		}
	}
	if topK < len(results) {
		return results[:topK]
	}
	return results
}

// ---------------------------------------------------------------------------
// Orchestrator
// ---------------------------------------------------------------------------

type EvidenceBundle struct {
	Business        *BusinessData
	StructuredScore float64
	ReviewResults   []ReviewSearchResult
	PhotoResults    []PhotoSearchResult
	FinalScore      float64
	ConflictNotes   []string
}

func orchestrate(
	structured []StructuredSearchResult,
	reviews []ReviewSearchResult,
	photos []PhotoSearchResult,
) EvidenceBundle {
	b := EvidenceBundle{
		ReviewResults: reviews,
		PhotoResults:  photos,
	}
	if len(structured) > 0 {
		biz := structured[0].Business
		b.Business = &biz
		b.StructuredScore = structured[0].Score
	}
	// conflict detection
	if b.Business != nil {
		for k, v := range b.Business.Amenities {
			label := strings.ReplaceAll(k, "_", " ")
			for _, rr := range reviews {
				if strings.Contains(strings.ToLower(rr.Review.Text), label) && !v {
					b.ConflictNotes = append(b.ConflictNotes,
						fmt.Sprintf("Canonical data: no %s. Some reviews mention '%s' — treat as anecdotal.", label, label))
					break
				}
			}
		}
	}
	avgReview := 0.0
	for _, r := range reviews {
		avgReview += r.SimilarityScore
	}
	if len(reviews) > 0 {
		avgReview /= float64(len(reviews))
	}
	avgPhoto := 0.0
	for _, p := range photos {
		avgPhoto += p.CombinedScore()
	}
	if len(photos) > 0 {
		avgPhoto /= float64(len(photos))
	}
	b.FinalScore = math.Round((0.4*b.StructuredScore+0.3*avgReview+0.3*avgPhoto)*10000) / 10000
	return b
}

// ---------------------------------------------------------------------------
// Mock RAG service
// ---------------------------------------------------------------------------

func generateAnswer(query string, intent QueryIntent, b EvidenceBundle) string {
	switch intent {
	case IntentOperational:
		if b.Business != nil && len(b.Business.Hours) > 0 {
			parts := make([]string, 0, len(b.Business.Hours))
			for _, h := range b.Business.Hours {
				if h.IsClosed {
					parts = append(parts, fmt.Sprintf("%s: Closed", strings.Title(h.Day)))
				} else {
					parts = append(parts, fmt.Sprintf("%s: %s–%s", strings.Title(h.Day), h.OpenTime, h.CloseTime))
				}
			}
			return fmt.Sprintf("Business hours for %s: %s.", b.Business.Name, strings.Join(parts, "; "))
		}
		return "Business hours are not available."

	case IntentAmenity:
		if b.Business != nil && len(b.Business.Amenities) > 0 {
			q := strings.ToLower(query)
			for k, v := range b.Business.Amenities {
				label := strings.ReplaceAll(k, "_", " ")
				if strings.Contains(q, label) || strings.Contains(q, k) {
					status := "No"
					if v {
						status = "Yes"
					}
					ans := fmt.Sprintf("%s — %s: %s (canonical).", b.Business.Name, label, status)
					if len(b.ConflictNotes) > 0 {
						ans += " Note: " + b.ConflictNotes[0]
					}
					return ans
				}
			}
		}
		return "Amenity information is not available in our records."

	case IntentQuality:
		if len(b.ReviewResults) > 0 {
			total := 0.0
			for _, r := range b.ReviewResults {
				total += r.Review.Rating
			}
			avg := total / float64(len(b.ReviewResults))
			return fmt.Sprintf("Based on %d relevant review(s), average rating: %.1f/5.", len(b.ReviewResults), avg)
		}
		return "No relevant reviews found to assess quality."

	case IntentPhoto:
		if len(b.PhotoResults) > 0 {
			captions := make([]string, 0)
			for _, p := range b.PhotoResults {
				if p.Photo.Caption != "" {
					captions = append(captions, p.Photo.Caption)
				}
			}
			if len(captions) > 0 {
				return fmt.Sprintf("Found %d photo(s): %s", len(b.PhotoResults), strings.Join(captions, "; "))
			}
		}
		return "No matching photos found."

	default:
		if b.Business != nil {
			return fmt.Sprintf("%s is located at %s. Rating: %.1f/5. Phone: %s.",
				b.Business.Name, b.Business.Address, b.Business.Rating, b.Business.Phone)
		}
		return "I could not find a specific answer to your question."
	}
}

// ---------------------------------------------------------------------------
// LRU Cache
// ---------------------------------------------------------------------------

const (
	cacheMaxSize = 10000
	cacheTTL     = 5 * time.Minute
)

type cacheEntry struct {
	key       string
	value     QueryResponse
	expiresAt time.Time
}

type QueryCache struct {
	mu      sync.Mutex
	items   map[string]*list.Element
	order   *list.List
	maxSize int
}

func NewQueryCache() *QueryCache {
	return &QueryCache{
		items:   make(map[string]*list.Element),
		order:   list.New(),
		maxSize: cacheMaxSize,
	}
}

func cacheKey(businessID, query string) string {
	h := sha256.Sum256([]byte(businessID + ":" + query))
	return fmt.Sprintf("%x", h[:8])
}

func (c *QueryCache) Get(businessID, query string) (QueryResponse, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	k := cacheKey(businessID, query)
	el, ok := c.items[k]
	if !ok {
		return QueryResponse{}, false
	}
	entry := el.Value.(*cacheEntry)
	if time.Now().After(entry.expiresAt) {
		c.order.Remove(el)
		delete(c.items, k)
		return QueryResponse{}, false
	}
	c.order.MoveToFront(el)
	return entry.value, true
}

func (c *QueryCache) Set(businessID, query string, resp QueryResponse) {
	c.mu.Lock()
	defer c.mu.Unlock()
	k := cacheKey(businessID, query)
	if el, ok := c.items[k]; ok {
		c.order.MoveToFront(el)
		el.Value.(*cacheEntry).value = resp
		el.Value.(*cacheEntry).expiresAt = time.Now().Add(cacheTTL)
		return
	}
	entry := &cacheEntry{key: k, value: resp, expiresAt: time.Now().Add(cacheTTL)}
	el := c.order.PushFront(entry)
	c.items[k] = el
	for c.order.Len() > c.maxSize {
		back := c.order.Back()
		if back == nil {
			break
		}
		e := back.Value.(*cacheEntry)
		delete(c.items, e.key)
		c.order.Remove(back)
	}
}

func (c *QueryCache) Size() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.order.Len()
}

// ---------------------------------------------------------------------------
// Circuit Breaker
// ---------------------------------------------------------------------------

type CircuitState int

const (
	StateClosed   CircuitState = iota
	StateOpen
	StateHalfOpen
)

type CircuitBreaker struct {
	mu               sync.Mutex
	name             string
	failureThreshold int
	recoveryTimeout  time.Duration
	state            CircuitState
	failureCount     int
	lastFailure      time.Time
}

func NewCircuitBreaker(name string) *CircuitBreaker {
	return &CircuitBreaker{
		name:             name,
		failureThreshold: 5,
		recoveryTimeout:  30 * time.Second,
		state:            StateClosed,
	}
}

func (cb *CircuitBreaker) IsOpen() bool {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	if cb.state == StateOpen {
		if time.Since(cb.lastFailure) >= cb.recoveryTimeout {
			cb.state = StateHalfOpen
			return false
		}
		return true
	}
	return false
}

func (cb *CircuitBreaker) RecordSuccess() {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	cb.failureCount = 0
	cb.state = StateClosed
}

func (cb *CircuitBreaker) RecordFailure() {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	cb.failureCount++
	cb.lastFailure = time.Now()
	if cb.failureCount >= cb.failureThreshold {
		cb.state = StateOpen
	}
}

func (cb *CircuitBreaker) StateName() string {
	cb.mu.Lock()
	defer cb.mu.Unlock()
	switch cb.state {
	case StateClosed:
		return "closed"
	case StateOpen:
		return "open"
	default:
		return "half_open"
	}
}

// ---------------------------------------------------------------------------
// Application State
// ---------------------------------------------------------------------------

type AppState struct {
	structured *StructuredSearchService
	reviews    *ReviewVectorSearchService
	photos     *PhotoHybridRetrievalService
	cache      *QueryCache
	cbStruct   *CircuitBreaker
	cbReview   *CircuitBreaker
	cbPhoto    *CircuitBreaker
}

func seedDemoData(s *AppState) {
	biz := BusinessData{
		BusinessID: "12345",
		Name:       "The Rustic Table",
		Address:    "123 Main St, New York, NY 10001",
		Phone:      "+1-212-555-0100",
		PriceRange: "$$",
		Hours: []BusinessHours{
			{"monday", "09:00", "22:00", false},
			{"tuesday", "09:00", "22:00", false},
			{"wednesday", "09:00", "22:00", false},
			{"thursday", "09:00", "22:00", false},
			{"friday", "09:00", "23:00", false},
			{"saturday", "10:00", "23:00", false},
			{"sunday", "10:00", "21:00", false},
		},
		Amenities: map[string]bool{
			"heated_patio":         true,
			"parking":              false,
			"wifi":                 true,
			"wheelchair_accessible": true,
		},
		Categories:  []string{"American", "Brunch", "Bar"},
		Rating:      4.3,
		ReviewCount: 215,
	}
	s.structured.Add(biz)

	s.reviews.Add(Review{"r1", "12345", "u1", 5.0, "Amazing heated patio — perfect for winter evenings. Great cocktails too!"})
	s.reviews.Add(Review{"r2", "12345", "u2", 4.0, "Lovely atmosphere for a date night. The food was excellent."})
	s.reviews.Add(Review{"r3", "12345", "u3", 3.5, "Good for groups. Parking nearby is tricky on weekends."})

	s.photos.Add(Photo{"p1", "12345", "https://example.com/photos/rustic-patio-1.jpg", "Outdoor heated patio with string lights in winter"})
	s.photos.Add(Photo{"p2", "12345", "https://example.com/photos/rustic-interior.jpg", "Cozy interior with rustic wooden decor"})
}

// ---------------------------------------------------------------------------
// HTTP Handlers
// ---------------------------------------------------------------------------

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func correlationMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		corr := r.Header.Get("X-Correlation-ID")
		if corr == "" {
			corr = fmt.Sprintf("%d", time.Now().UnixNano())
		}
		w.Header().Set("X-Correlation-ID", corr)
		next.ServeHTTP(w, r)
	})
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"status":  "healthy",
		"service": "yelp-ai-assistant",
		"version": "1.0.0",
	})
}

func handleHealthDetailed(state *AppState) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{
			"status":  "healthy",
			"service": "yelp-ai-assistant",
			"version": "1.0.0",
			"circuit_breakers": map[string]string{
				"structured_search":   state.cbStruct.StateName(),
				"review_vector_search": state.cbReview.StateName(),
				"photo_hybrid_search": state.cbPhoto.StateName(),
			},
			"cache": map[string]int{
				"l1_entries": state.cache.Size(),
			},
		})
	}
}

func handleQuery(state *AppState) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		start := time.Now()

		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "cannot read body", http.StatusBadRequest)
			return
		}
		var req QueryRequest
		if err := json.Unmarshal(body, &req); err != nil || req.Query == "" || req.BusinessID == "" {
			http.Error(w, "invalid request body", http.StatusBadRequest)
			return
		}

		// 1. Cache check
		if cached, ok := state.cache.Get(req.BusinessID, req.Query); ok {
			writeJSON(w, http.StatusOK, cached)
			return
		}

		// 2. Intent classification
		intent := classifyIntent(req.Query)

		// 3. Routing
		decision := routeIntent(intent)

		// 4. Parallel search
		type searchOut struct {
			structured []StructuredSearchResult
			reviews    []ReviewSearchResult
			photos     []PhotoSearchResult
		}
		out := searchOut{}
		var wg sync.WaitGroup

		if decision.UseStructured && !state.cbStruct.IsOpen() {
			wg.Add(1)
			go func() {
				defer wg.Done()
				out.structured = state.structured.Search(req.Query, req.BusinessID)
				state.cbStruct.RecordSuccess()
			}()
		}
		if decision.UseReviewVector && !state.cbReview.IsOpen() {
			wg.Add(1)
			go func() {
				defer wg.Done()
				out.reviews = state.reviews.Search(req.Query, req.BusinessID, 5)
				state.cbReview.RecordSuccess()
			}()
		}
		if decision.UsePhotoHybrid && !state.cbPhoto.IsOpen() {
			wg.Add(1)
			go func() {
				defer wg.Done()
				out.photos = state.photos.Search(req.Query, req.BusinessID, 5)
				state.cbPhoto.RecordSuccess()
			}()
		}
		wg.Wait()

		// 5. Orchestrate
		bundle := orchestrate(out.structured, out.reviews, out.photos)

		// 6. Generate answer
		answer := generateAnswer(req.Query, intent, bundle)

		resp := QueryResponse{
			Answer:     answer,
			Confidence: bundle.FinalScore,
			Intent:     intent,
			Evidence: EvidenceSummary{
				Structured:  bundle.Business != nil,
				ReviewsUsed: len(bundle.ReviewResults),
				PhotosUsed:  len(bundle.PhotoResults),
			},
			LatencyMs: float64(time.Since(start).Microseconds()) / 1000.0,
		}

		// 7. Cache and return
		state.cache.Set(req.BusinessID, req.Query, resp)
		writeJSON(w, http.StatusOK, resp)
	}
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

func main() {
	state := &AppState{
		structured: NewStructuredSearchService(),
		reviews:    NewReviewVectorSearchService(),
		photos:     NewPhotoHybridRetrievalService(),
		cache:      NewQueryCache(),
		cbStruct:   NewCircuitBreaker("structured_search"),
		cbReview:   NewCircuitBreaker("review_vector_search"),
		cbPhoto:    NewCircuitBreaker("photo_hybrid_search"),
	}
	seedDemoData(state)

	mux := http.NewServeMux()
	mux.HandleFunc("/health", handleHealth)
	mux.HandleFunc("/health/detailed", handleHealthDetailed(state))
	mux.HandleFunc("/assistant/query", handleQuery(state))

	handler := correlationMiddleware(mux)

	addr := ":8080"
	log.Printf("🚀 Yelp-Style AI Assistant (Go) listening on %s", addr)
	log.Printf("📖 Endpoints: POST /assistant/query  GET /health  GET /health/detailed")
	log.Fatal(http.ListenAndServe(addr, handler))
}
