import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.values.PCollection;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.UUID;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@SpringBootApplication
public class LotteryApplication {

    public static void main(String[] args) {
        SpringApplication.run(LotteryApplication.class, args);
    }

    /**
     * A service that encapsulates the Apache Beam pipeline logic.
     */
    @Service
    public static class BeamPipelineService {

        public void runPipeline() {
            PipelineOptions options = PipelineOptionsFactory.create();
            Pipeline pipeline = Pipeline.create(options);

            PCollection<String> input = pipeline.apply("ReadTickets", PubsubIO.readStrings()
                .fromSubscription("projects/your-gcp-project/subscriptions/tickets-subscription"));

            PCollection<String> validatedTickets = input.apply("ValidateAndTransformTickets", 
                ParDo.of(new ValidateAndTransformTicketFn()));

            validatedTickets.apply("WriteToBigQuery", ...); // BigQuery writing setup

            pipeline.run().waitUntilFinish();
        }

        /**
         * A custom DoFn to process each ticket, perform validation, 
         * generate UUID, and compute dates.
         */
        static class ValidateAndTransformTicketFn extends DoFn<String, String> {
            @ProcessElement
            public void processElement(ProcessContext c) {
                String[] parts = c.element().split(",");
                if (parts.length > 1 && parts[0].length() == 6 && parts[0].matches("[0-9]+")) {
                    String uuid = UUID.randomUUID().toString();
                    LocalDate drawDate = LocalDate.parse(parts[1], DateTimeFormatter.ISO_LOCAL_DATE);
                    LocalDate prizeCollectionDate = drawDate.plusDays(30);
                    
                    String output = uuid + "," + parts[0] + "," + parts[1] + "," +
                                    drawDate + "," + prizeCollectionDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
                    c.output(output);
                }
            }
        }
    }

    /**
     * Controller to manage lottery operations via REST API.
     */
    @RestController
    @RequestMapping("/api/lottery")
    public class LotteryController {

        @Autowired
        private BeamPipelineService beamService;

        @GetMapping("/start")
        public String startPipeline() {
            beamService.runPipeline();
            return "Pipeline started successfully.";
        }
    }
}
