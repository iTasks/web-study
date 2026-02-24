package com.yelp.assistant.controller;

import com.yelp.assistant.cache.QueryCache;
import com.yelp.assistant.intent.IntentClassifier;
import com.yelp.assistant.model.*;
import com.yelp.assistant.orchestration.EvidenceBundle;
import com.yelp.assistant.rag.RagService;
import com.yelp.assistant.resilience.CircuitBreaker;
import com.yelp.assistant.routing.QueryRouter;
import com.yelp.assistant.search.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@RestController
public class AssistantController {

    private final IntentClassifier classifier;
    private final QueryRouter router;
    private final StructuredSearchService structuredService;
    private final ReviewVectorSearchService reviewService;
    private final PhotoHybridRetrievalService photoService;
    private final RagService ragService;
    private final QueryCache cache;
    private final CircuitBreaker cbStructured;
    private final CircuitBreaker cbReview;
    private final CircuitBreaker cbPhoto;

    public AssistantController(
        IntentClassifier classifier,
        QueryRouter router,
        StructuredSearchService structuredService,
        ReviewVectorSearchService reviewService,
        PhotoHybridRetrievalService photoService,
        RagService ragService,
        QueryCache cache,
        @Qualifier("cbStructured") CircuitBreaker cbStructured,
        @Qualifier("cbReview")     CircuitBreaker cbReview,
        @Qualifier("cbPhoto")      CircuitBreaker cbPhoto
    ) {
        this.classifier      = classifier;
        this.router          = router;
        this.structuredService = structuredService;
        this.reviewService   = reviewService;
        this.photoService    = photoService;
        this.ragService      = ragService;
        this.cache           = cache;
        this.cbStructured    = cbStructured;
        this.cbReview        = cbReview;
        this.cbPhoto         = cbPhoto;
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("status", "healthy", "service", "yelp-ai-assistant", "version", "1.0.0");
    }

    @GetMapping("/health/detailed")
    public Map<String, Object> healthDetailed() {
        return Map.of(
            "status", "healthy",
            "service", "yelp-ai-assistant",
            "version", "1.0.0",
            "circuit_breakers", Map.of(
                "structured_search",    cbStructured.stateName(),
                "review_vector_search", cbReview.stateName(),
                "photo_hybrid_search",  cbPhoto.stateName()
            ),
            "cache", Map.of("l1_entries", cache.size())
        );
    }

    @PostMapping("/assistant/query")
    public ResponseEntity<QueryResponse> query(@Valid @RequestBody QueryRequest request) {
        long start = System.nanoTime();

        // 1. Cache check
        var cached = cache.get(request.businessId(), request.query());
        if (cached.isPresent()) return ResponseEntity.ok(cached.get());

        // 2. Intent classification
        QueryIntent intent = classifier.classify(request.query());

        // 3. Routing decision
        RoutingDecision decision = router.decide(intent);

        // 4. Parallel search
        CompletableFuture<List<StructuredSearchResult>> fStruct = decision.useStructured() && !cbStructured.isOpen()
            ? CompletableFuture.supplyAsync(() -> {
                var r = structuredService.search(request.query(), request.businessId());
                cbStructured.recordSuccess();
                return r;
              })
            : CompletableFuture.completedFuture(List.of());

        CompletableFuture<List<ReviewSearchResult>> fReview = decision.useReviewVector() && !cbReview.isOpen()
            ? CompletableFuture.supplyAsync(() -> {
                var r = reviewService.search(request.query(), request.businessId(), 5);
                cbReview.recordSuccess();
                return r;
              })
            : CompletableFuture.completedFuture(List.of());

        CompletableFuture<List<PhotoSearchResult>> fPhoto = decision.usePhotoHybrid() && !cbPhoto.isOpen()
            ? CompletableFuture.supplyAsync(() -> {
                var r = photoService.search(request.query(), request.businessId(), 5);
                cbPhoto.recordSuccess();
                return r;
              })
            : CompletableFuture.completedFuture(List.of());

        CompletableFuture.allOf(fStruct, fReview, fPhoto).join();

        // 5. Orchestrate
        EvidenceBundle bundle = EvidenceBundle.build(fStruct.join(), fReview.join(), fPhoto.join());

        // 6. Generate answer
        String answer = ragService.generateAnswer(request.query(), intent, bundle);
        double latencyMs = (System.nanoTime() - start) / 1_000_000.0;

        QueryResponse response = new QueryResponse(
            answer,
            bundle.finalScore(),
            intent,
            new EvidenceSummary(
                bundle.business() != null,
                bundle.reviewResults().size(),
                bundle.photoResults().size()
            ),
            Math.round(latencyMs * 10.0) / 10.0
        );

        // 7. Cache and return
        cache.set(request.businessId(), request.query(), response);
        return ResponseEntity.ok(response);
    }
}
