package ca.bazlur.hive.reactive;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.transaction.TransactionAutoConfiguration;

@SpringBootApplication(exclude = {
    TransactionAutoConfiguration.class
})
public class ReactiveHiveApplication {
  public static void main(String[] args) {
    SpringApplication.run(ReactiveHiveApplication.class, args);
  }
}
