package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.TemperatureReading;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Sinks;

@Component
public class SseBroadcaster {
    private final Sinks.Many<TemperatureReading> sink =
            Sinks.many().multicast().onBackpressureBuffer();

    public Mono<Void> broadcast(TemperatureReading reading) {
        return Mono.fromRunnable(() -> sink.tryEmitNext(reading));
    }

    public Flux<TemperatureReading> flux() {
        return sink.asFlux();
    }
}
