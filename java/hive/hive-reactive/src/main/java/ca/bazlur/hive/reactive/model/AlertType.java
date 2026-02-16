package ca.bazlur.hive.reactive.model;

public enum AlertType {
    HIGH_TEMP("Temperature too high"),
    LOW_TEMP("Temperature too low"),
    ABNORMAL_DELTA("Abnormal indoor/outdoor temperature difference");

    private final String description;

    AlertType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
