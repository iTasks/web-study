package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.model.Alert;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * SSE broadcaster for alerts using simple CopyOnWriteArrayList.
 *
 * Compare with reactive version which uses Sinks.Many with backpressure -
 * this is simpler and equally effective for most use cases.
 */
@Service
public class AlertBroadcaster {
    private static final Logger log = LoggerFactory.getLogger(AlertBroadcaster.class);
    private final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    public void broadcast(Alert alert) {
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event()
                        .name("alert")
                        .data(alert));
            } catch (IOException e) {
                emitters.remove(emitter);
                log.debug("Removed dead alert emitter");
            }
        }
    }

    public SseEmitter register() {
        SseEmitter emitter = new SseEmitter(0L);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        emitter.onError(_ -> emitters.remove(emitter));
        emitters.add(emitter);
        return emitter;
    }
}
