package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.Alert;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Sinks;

/**
 * SSE broadcaster for alerts using reactive Sinks.
 *
 * Compare with virtual threads version which uses CopyOnWriteArrayList
 * of SseEmitter - this is more complex but handles backpressure automatically.
 */
@Service
public class AlertBroadcaster {
    private final Sinks.Many<Alert> sink = Sinks.many().multicast().onBackpressureBuffer();

    public Mono<Void> broadcast(Alert alert) {
        return Mono.fromRunnable(() -> sink.tryEmitNext(alert));
    }

    public Flux<Alert> flux() {
        return sink.asFlux();
    }
}
