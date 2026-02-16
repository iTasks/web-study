package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.HourlyStat;
import ca.bazlur.hive.reactive.model.SensorAggregate;
import ca.bazlur.hive.reactive.model.TemperatureReading;
import ca.bazlur.hive.reactive.repository.AggregationRepository;
import ca.bazlur.hive.reactive.repository.ReadingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

/**
 * Aggregation Service demonstrating reactive complexity.
 *
 * This service showcases Reactor operators for data aggregation:
 * - flatMap() for async transformations
 * - collectList() for gathering results
 * - Flux.fromIterable() for converting collections
 * - groupBy() for partitioning data streams
 *
 * Compare with virtual threads version which uses simple Stream.collect(groupingBy()).
 */
@Service
public class AggregationService {
    private static final Logger log = LoggerFactory.getLogger(AggregationService.class);
    private static final int DEFAULT_WINDOW_MINUTES = 5;

    private final AggregationRepository aggregationRepository;
    private final ReadingRepository readingRepository;

    public AggregationService(AggregationRepository aggregationRepository,
                              ReadingRepository readingRepository) {
        this.aggregationRepository = aggregationRepository;
        this.readingRepository = readingRepository;
    }

    /**
     * Get rolling aggregate for a specific sensor.
     */
    public Mono<SensorAggregate> getRollingAggregate(String sensorId) {
        return aggregationRepository.calculateRollingAggregate(sensorId, DEFAULT_WINDOW_MINUTES);
    }

    /**
     * Get rolling aggregates for all sensors.
     *
     * Reactive complexity:
     * - Flux from database query
     * - Each element is already aggregated by the DB
     */
    public Flux<SensorAggregate> getAllRollingAggregates() {
        return aggregationRepository.calculateAllRollingAggregates(DEFAULT_WINDOW_MINUTES);
    }

    /**
     * Get hourly stats for a sensor.
     */
    public Flux<HourlyStat> getHourlyStats(String sensorId, int hours) {
        return aggregationRepository.findHourlyStats(sensorId, hours);
    }

    /**
     * Compute and store hourly statistics.
     * Runs every hour at minute 0.
     *
     * Reactive complexity:
     * - Scheduled method returning void but internally reactive
     * - flatMap to process each sensor's readings
     * - flatMap to save each computed stat
     * - subscribe() to trigger the chain
     */
    @Scheduled(cron = "0 0 * * * *")
    public void computeHourlyStats() {
        Instant hourStart = Instant.now().truncatedTo(ChronoUnit.HOURS).minus(1, ChronoUnit.HOURS);

        log.info("Computing hourly stats for hour starting at {}", hourStart);

        readingRepository.latestTemperatures()
                .map(TemperatureReading::sensorId)
                .distinct()
                .flatMap(sensorId -> computeAndSaveHourlyStat(sensorId, hourStart))
                .doOnComplete(() -> log.info("Hourly stats computation complete"))
                .doOnError(e -> log.error("Error computing hourly stats", e))
                .subscribe();
    }

    private Mono<HourlyStat> computeAndSaveHourlyStat(String sensorId, Instant hourStart) {
        return aggregationRepository.calculateRollingAggregate(sensorId, 60)
                .map(agg -> new HourlyStat(
                        null,
                        sensorId,
                        hourStart,
                        agg.avgTemp(),
                        agg.minTemp(),
                        agg.maxTemp(),
                        agg.readingCount()
                ))
                .flatMap(stat -> aggregationRepository.saveHourlyStat(stat).thenReturn(stat))
                .doOnNext(stat -> log.debug("Saved hourly stat for sensor {}: avg={}°C",
                        stat.sensorId(), stat.avgTemp()));
    }
}
