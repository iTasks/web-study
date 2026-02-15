package ca.bazlur.hive.vthreads;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class VthreadsHiveApplication {
    public static void main(String[] args) {
        SpringApplication.run(VthreadsHiveApplication.class, args);
    }
}
