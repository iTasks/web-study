package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.model.HourlyStat;
import ca.bazlur.hive.vthreads.model.SensorAggregate;
import ca.bazlur.hive.vthreads.model.TemperatureReading;
import ca.bazlur.hive.vthreads.repository.AggregationRepository;
import ca.bazlur.hive.vthreads.repository.ReadingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Aggregation Service demonstrating virtual threads simplicity.
 *
 * Compare with reactive version:
 * - Simple method calls (vs flatMap chains)
 * - Stream.collect() (vs Flux.groupBy().flatMap())
 * - for-each loops (vs subscribe())
 *
 * The logic is identical but the code is immediately readable.
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
    public SensorAggregate getRollingAggregate(String sensorId) {
        return aggregationRepository.calculateRollingAggregate(sensorId, DEFAULT_WINDOW_MINUTES);
    }

    /**
     * Get rolling aggregates for all sensors.
     *
     * Virtual threads simplicity:
     * - Simple method call returns List
     * - No Flux, no subscribe, no reactive chain
     */
    public List<SensorAggregate> getAllRollingAggregates() {
        return aggregationRepository.calculateAllRollingAggregates(DEFAULT_WINDOW_MINUTES);
    }

    /**
     * Get hourly stats for a sensor.
     */
    public List<HourlyStat> getHourlyStats(String sensorId, int hours) {
        return aggregationRepository.findHourlyStats(sensorId, hours);
    }

    /**
     * Compute and store hourly statistics.
     * Runs every hour at minute 0.
     *
     * Virtual threads simplicity:
     * - Simple for-each loop
     * - Direct method calls
     * - No subscribe(), no reactive chains
     */
    @Scheduled(cron = "0 0 * * * *")
    public void computeHourlyStats() {
        Instant hourStart = Instant.now().truncatedTo(ChronoUnit.HOURS).minus(1, ChronoUnit.HOURS);

        log.info("Computing hourly stats for hour starting at {}", hourStart);

        // Get all unique sensor IDs
        Set<String> sensorIds = readingRepository.latestTemperatures().stream()
                .map(TemperatureReading::sensorId)
                .collect(Collectors.toSet());

        // Compute and save stats for each sensor
        for (String sensorId : sensorIds) {
            computeAndSaveHourlyStat(sensorId, hourStart);
        }

        log.info("Hourly stats computation complete");
    }

    private void computeAndSaveHourlyStat(String sensorId, Instant hourStart) {
        SensorAggregate agg = aggregationRepository.calculateRollingAggregate(sensorId, 60);

        HourlyStat stat = new HourlyStat(
                null,
                sensorId,
                hourStart,
                agg.avgTemp(),
                agg.minTemp(),
                agg.maxTemp(),
                agg.readingCount()
        );

        aggregationRepository.saveHourlyStat(stat);
        log.debug("Saved hourly stat for sensor {}: avg={}°C", stat.sensorId(), stat.avgTemp());
    }
}
