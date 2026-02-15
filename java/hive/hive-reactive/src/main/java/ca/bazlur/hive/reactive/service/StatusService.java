package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.BuildingStatus;
import ca.bazlur.hive.reactive.model.TemperatureReading;
import ca.bazlur.hive.reactive.repository.ReadingRepository;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;

@Service
public class StatusService {
    private final ReadingRepository repository;

    public StatusService(ReadingRepository repository) {
        this.repository = repository;
    }

    public Mono<BuildingStatus> status() {
        return repository.latestTemperatures().collectList().map(this::aggregate);
    }

    private BuildingStatus aggregate(List<TemperatureReading> readings) {
        if (readings.isEmpty()) {
            return new BuildingStatus(0, 0, 0, 0, Instant.now());
        }
        double min = readings.stream().mapToDouble(TemperatureReading::temperature).min().orElse(0);
        double max = readings.stream().mapToDouble(TemperatureReading::temperature).max().orElse(0);
        double avg = readings.stream().mapToDouble(TemperatureReading::temperature).average().orElse(0);
        return new BuildingStatus(readings.size(), min, max, avg, Instant.now());
    }
}
