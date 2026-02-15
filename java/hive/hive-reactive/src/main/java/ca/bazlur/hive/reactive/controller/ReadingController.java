package ca.bazlur.hive.reactive.controller;

import ca.bazlur.hive.reactive.model.Alert;
import ca.bazlur.hive.reactive.model.BuildingStatus;
import ca.bazlur.hive.reactive.model.ReadingDetails;
import ca.bazlur.hive.reactive.model.HourlyStat;
import ca.bazlur.hive.reactive.model.ProcessingResult;
import ca.bazlur.hive.reactive.model.SensorAggregate;
import ca.bazlur.hive.reactive.model.TemperatureReading;
import ca.bazlur.hive.reactive.repository.ReadingRepository;
import ca.bazlur.hive.reactive.service.AggregationService;
import ca.bazlur.hive.reactive.service.AlertBroadcaster;
import ca.bazlur.hive.reactive.service.AlertService;
import ca.bazlur.hive.reactive.service.IngestionService;
import ca.bazlur.hive.reactive.service.SseBroadcaster;
import ca.bazlur.hive.reactive.service.StatusService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.codec.ServerSentEvent;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Duration;

@RestController
@RequestMapping("/api")
public class ReadingController {
    private final IngestionService ingestionService;
    private final ReadingRepository repository;
    private final StatusService statusService;
    private final SseBroadcaster broadcaster;
    private final AlertService alertService;
    private final AlertBroadcaster alertBroadcaster;
    private final AggregationService aggregationService;

    public ReadingController(
            IngestionService ingestionService,
            ReadingRepository repository,
            StatusService statusService,
            SseBroadcaster broadcaster,
            AlertService alertService,
            AlertBroadcaster alertBroadcaster,
            AggregationService aggregationService
    ) {
        this.ingestionService = ingestionService;
        this.repository = repository;
        this.statusService = statusService;
        this.broadcaster = broadcaster;
        this.alertService = alertService;
        this.alertBroadcaster = alertBroadcaster;
        this.aggregationService = aggregationService;
    }

    @PostMapping("/readings")
    public Mono<ProcessingResult> submit(@Valid @RequestBody TemperatureReading reading) {
        return ingestionService.process(reading);
    }

    @GetMapping("/readings/{sensorId}")
    public Mono<ReadingDetails> latest(@PathVariable("sensorId") String sensorId) {
        return repository.latest(sensorId)
                .switchIfEmpty(Mono.error(new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Sensor not found")));
    }

    @GetMapping("/readings/history")
    public Flux<ReadingDetails> history(@RequestParam(value = "sensorId", required = false) String sensorId) {
        return repository.history(sensorId);
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ServerSentEvent<TemperatureReading>> stream() {

        return broadcaster.flux()
            .map(data -> ServerSentEvent.builder(data)
                .event("temperature")
                .build())
            .mergeWith(
                Flux.interval(Duration.ofSeconds(15))
                    .map(_ -> ServerSentEvent.<TemperatureReading>builder()
                        .comment("keep-alive")
                        .build())
            );
    }


    @GetMapping("/status")
    public Mono<BuildingStatus> status() {
        return statusService.status();
    }

    @GetMapping("/alerts")
    public Flux<Alert> getAlerts(@RequestParam(value = "limit", defaultValue = "50") int limit) {
        return alertService.getRecentAlerts(limit);
    }

    @GetMapping("/alerts/unacknowledged")
    public Flux<Alert> getUnacknowledgedAlerts() {
        return alertService.getUnacknowledgedAlerts();
    }

    @PostMapping("/alerts/{id}/acknowledge")
    public Mono<ResponseEntity<Void>> acknowledgeAlert(@PathVariable("id") Long id) {
        return alertService.acknowledgeAlert(id)
                .thenReturn(ResponseEntity.ok().build());
    }

    @GetMapping(value = "/alerts/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ServerSentEvent<Alert>> alertStream() {
        return alertBroadcaster.flux()
                .map(alert -> ServerSentEvent.builder(alert)
                        .event("alert")
                        .build())
                .mergeWith(
                        Flux.interval(Duration.ofSeconds(15))
                                .map(_ -> ServerSentEvent.<Alert>builder()
                                        .comment("keep-alive")
                                        .build())
                );
    }

    @GetMapping("/aggregates")
    public Flux<SensorAggregate> getAggregates() {
        return aggregationService.getAllRollingAggregates();
    }

    @GetMapping("/aggregates/{sensorId}")
    public Mono<SensorAggregate> getAggregate(@PathVariable("sensorId") String sensorId) {
        return aggregationService.getRollingAggregate(sensorId);
    }

    @GetMapping("/aggregates/{sensorId}/hourly")
    public Flux<HourlyStat> getHourlyStats(
            @PathVariable("sensorId") String sensorId,
            @RequestParam(value = "hours", defaultValue = "24") int hours) {
        return aggregationService.getHourlyStats(sensorId, hours);
    }
}
