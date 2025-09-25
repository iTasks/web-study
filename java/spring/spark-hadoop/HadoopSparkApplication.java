import org.apache.spark.sql.SparkSession;
import org.apache.hadoop.conf.Configuration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

@SpringBootApplication
public class HadoopSparkApplication {

    public static void main(String[] args) {
        SpringApplication.run(HadoopSparkApplication.class, args);
    }

    @Bean
    public SparkSession sparkSession() {
        return SparkSession.builder()
            .appName("SpringBootSparkHadoopIntegration")
            .master("local[*]")
            .getOrCreate();
    }

    @Bean
    public Configuration hadoopConfiguration() {
        Configuration configuration = new Configuration();
        configuration.set("fs.defaultFS", "hdfs://localhost:9000");
        return configuration;
    }
}

@RestController
class SparkController {

    @Autowired
    private SparkSession sparkSession;

    @GetMapping("/spark-test")
    public String testSpark() {
        long count = sparkSession.read().json("hdfs://localhost:9000/example.json").count();
        return "Count of records: " + count;
    }
}

@RestController
class HadoopController {

    private final Configuration configuration;

    @Autowired
    public HadoopController(Configuration configuration) {
        this.configuration = configuration;
    }

    @GetMapping("/hadoop-test")
    public String testHadoop() {
        return configuration.get("fs.defaultFS");
    }
}

// JUnit Test
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class HadoopSparkApplicationTests {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void sparkEndpointTest() {
        String baseUrl = "http://localhost:" + port + "/spark-test";
        assert(this.restTemplate.getForObject(baseUrl, String.class).contains("Count of records:"));
    }

    @Test
    public void hadoopEndpointTest() {
        String baseUrl = "http://localhost:" + port + "/hadoop-test";
        assert(this.restTemplate.getForObject(baseUrl, String.class).equals("hdfs://localhost:9000"));
    }
}
