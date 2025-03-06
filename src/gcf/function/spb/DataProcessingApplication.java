package com.example.springdataproject;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.Filter;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

@SpringBootApplication
@RestController
public class DataProcessingApplication {

    public static void main(String[] args) {
        SpringApplication.run(DataProcessingApplication.class, args);
    }

    @GetMapping("/process-data")
    public String processData() {
        runBeamPipeline();  // Asynchronously handles data with Apache Beam
        runSparkJob();      // Processes data with Apache Spark
        return "Data processing initiated with Beam and processed by Spark. Check logs for details.";
    }

    private static void runBeamPipeline() {
        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline p = Pipeline.create(options);

        p.apply("ReadFromPubSub", PubsubIO.readStrings().fromSubscription("subscriptions/ticket-subscription"))
         .apply("ParseJSON", ParDo.of(new ParseTicketFn()))
         .apply("ValidateTickets", Filter.by((Ticket ticket) -> validateTicket(ticket)))
         .apply("WriteValidTicketsToIntermediateStore", TextIO.write().to("path/to/valid/tickets"));

         p.run().waitUntilFinish();
    }

    private static class ParseTicketFn extends DoFn<String, Ticket> {
        @ProcessElement
        public void processElement(@Element String json, OutputReceiver<Ticket> out) {
            ObjectMapper mapper = new ObjectMapper();
            try {
                Ticket ticket = mapper.readValue(json, Ticket.class);
                out.output(ticket);
            } catch (IOException e) {
                System.err.println("Failed to parse JSON: " + e.getMessage());
            }
        }
    }

    private static boolean validateTicket(Ticket ticket) {
        try {
            UUID uuid = UUID.fromString(ticket.uuid);  // Validate UUID
            int seatNumber = Integer.parseInt(ticket.seatNumber); // Validate seat number
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date ticketDate = sdf.parse(ticket.date); // Validate date
            Date expireTime = sdf.parse(ticket.expireTime); // Validate expiry

            boolean isDateValid = !ticketDate.before(new Date()); // Checks if date is not in the past
            boolean isNotExpired = !expireTime.before(new Date()); // Checks if ticket is not expired

            return isDateValid && isNotExpired && seatNumber > 0; 
        } catch (Exception e) {
            return false;
        }
    }

    private static void runSparkJob() {
        SparkSession spark = SparkSession
                                .builder()
                                .appName("Valid Ticket Data Processing")
                                .master("local[*]") // For local testing only
                                .getOrCreate();

        Dataset<String> ticketData = spark.read().textFile("path/to/valid/tickets/*");

        // Here, you could apply further transformations and actions with Spark
        spark.stop();
    }

    static class Ticket {
        public String uuid;
        public String seatNumber;
        public String date;
        public String expireTime;
    }
}
