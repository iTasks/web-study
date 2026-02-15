package ca.bazlur.hive.vthreads.controller;

import ca.bazlur.hive.vthreads.model.Alert;
import ca.bazlur.hive.vthreads.model.BuildingStatus;
import ca.bazlur.hive.vthreads.model.ReadingDetails;
import ca.bazlur.hive.vthreads.model.HourlyStat;
import ca.bazlur.hive.vthreads.model.ProcessingResult;
import ca.bazlur.hive.vthreads.model.SensorAggregate;
import ca.bazlur.hive.vthreads.model.TemperatureReading;
import ca.bazlur.hive.vthreads.repository.ReadingRepository;
import ca.bazlur.hive.vthreads.service.AggregationService;
import ca.bazlur.hive.vthreads.service.AlertBroadcaster;
import ca.bazlur.hive.vthreads.service.AlertService;
import ca.bazlur.hive.vthreads.service.IngestionService;
import ca.bazlur.hive.vthreads.service.SseBroadcaster;
import ca.bazlur.hive.vthreads.service.StatusService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;

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
    public ProcessingResult submit(@Valid @RequestBody TemperatureReading reading) {
        return ingestionService.process(reading);
    }

    @GetMapping("/readings/{sensorId}")
    public ReadingDetails latest(@PathVariable("sensorId") String sensorId) {
        ReadingDetails reading = repository.latest(sensorId);
        if (reading == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Sensor not found");
        }
        return reading;
    }

    @GetMapping("/readings/history")
    public List<ReadingDetails> history(@RequestParam(value = "sensorId", required = false) String sensorId) {
        return repository.history(sensorId);
    }

    @GetMapping("/stream")
    public SseEmitter stream() {
        return broadcaster.register();
    }

    @GetMapping("/status")
    public BuildingStatus status() {
        return statusService.status();
    }

    @GetMapping("/alerts")
    public List<Alert> getAlerts(@RequestParam(value = "limit", defaultValue = "50") int limit) {
        return alertService.getRecentAlerts(limit);
    }

    @GetMapping("/alerts/unacknowledged")
    public List<Alert> getUnacknowledgedAlerts() {
        return alertService.getUnacknowledgedAlerts();
    }

    @PostMapping("/alerts/{id}/acknowledge")
    public ResponseEntity<Void> acknowledgeAlert(@PathVariable("id") Long id) {
        alertService.acknowledgeAlert(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/alerts/stream")
    public SseEmitter alertStream() {
        return alertBroadcaster.register();
    }

    @GetMapping("/aggregates")
    public List<SensorAggregate> getAggregates() {
        return aggregationService.getAllRollingAggregates();
    }

    @GetMapping("/aggregates/{sensorId}")
    public SensorAggregate getAggregate(@PathVariable("sensorId") String sensorId) {
        return aggregationService.getRollingAggregate(sensorId);
    }

    @GetMapping("/aggregates/{sensorId}/hourly")
    public List<HourlyStat> getHourlyStats(
            @PathVariable("sensorId") String sensorId,
            @RequestParam(value = "hours", defaultValue = "24") int hours) {
        return aggregationService.getHourlyStats(sensorId, hours);
    }
}
