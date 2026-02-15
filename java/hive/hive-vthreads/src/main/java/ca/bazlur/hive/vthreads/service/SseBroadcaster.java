package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.model.TemperatureReading;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class SseBroadcaster {
    private final List<SseEmitter> subscribers = new CopyOnWriteArrayList<>();

    public SseEmitter register() {
        SseEmitter emitter = new SseEmitter(0L);
        subscribers.add(emitter);
        emitter.onCompletion(() -> subscribers.remove(emitter));
        emitter.onTimeout(() -> subscribers.remove(emitter));
        emitter.onError(_ -> subscribers.remove(emitter));
        return emitter;
    }

    public void broadcast(TemperatureReading reading) {
        for (SseEmitter emitter : subscribers) {
            try {
                emitter.send(SseEmitter.event().data(reading));
            } catch (IOException ex) {
                emitter.completeWithError(ex);
                subscribers.remove(emitter);
            }
        }
    }

    @Scheduled(fixedRate = 15000)
    public void sendHeartbeat() {
        for (SseEmitter emitter : subscribers) {
            try {
                emitter.send(SseEmitter.event().comment("heartbeat"));
            } catch (IOException ex) {
                subscribers.remove(emitter);
            }
        }
    }
}
