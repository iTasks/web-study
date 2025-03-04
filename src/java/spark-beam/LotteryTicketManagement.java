import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.values.TypeDescriptors;

import java.util.UUID;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Class enables the management of lottery tickets using Apache Beam and Google Cloud Services like Pub/Sub and BigQuery.
 * The system processes lottery tickets by validating them, generating unique UUIDs, and computing necessary dates.
 * This class assumes tickets are received via Pub/Sub and results are stored in BigQuery.
 * 
 * <p>Usage:</p>
 * <ul>
 *     <li>Make sure you have Apache Beam SDK, Google Cloud SDK set up in your environment</li>
 *     <li>Google Cloud project should be correctly configured with Pub/Sub and BigQuery</li>
 *     <li>This program expects Pub/Sub subscription and BigQuery dataset and table to exist</li>
 *     <li>Compile and run the program providing necessary arguments if required</li>
 * </ul>
 *
 * <p>Input:</p>
 * Reads strings from a Pub/Sub subscription where each string is expected to be in the format: "CustomerNumber,DrawDate"
 * <p>Output:</p>
 * Writes to BigQuery with schema:
 * UUID:STRING, CustomerNumber:STRING, DrawDate:DATE, PurchaseDate:DATE, PrizeCollectionDate:DATE
 *
 * @author MS Maruf + AI
 * @version 1.0
 */
public class LotteryTicketManagement {

    /**
     * A custom DoFn to process each ticket, perform validation, generate UUID, and compute dates.
     */
    public static class ValidateAndTransformTicketFn extends DoFn<String, String> {
        
        /**
         * Processes an element representing a lottery ticket. Validates the customer number, generates a UUID,
         * and computes the draw date and prize collection date.
         * 
         * @param c The processing context containing the input element.
         */
        @ProcessElement
        public void processElement(ProcessContext c) {
            String[] parts = c.element().split(",");
            if (parts.length > 2 && parts[1].length() == 6 && parts[1].matches("[0-9]+")) {
                String uuid = UUID.randomUUID().toString();
                LocalDate drawDate = LocalDate.parse(parts[2], DateTimeFormatter.ISO_LOCAL_DATE);
                LocalDate prizeCollectionDate = drawDate.plusDays(30);
                
                String output = uuid + "," + parts[1] + "," + parts[2] + "," +
                                drawDate + "," + prizeCollectionDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
                c.output(output);
            }
        }
    }
    
    /**
     * Main method which sets up and runs the Beam pipeline.
     * 
     * @param args Command line arguments; can be used to pass options to the Pipeline.
     */
    public static void main(String[] args) {
        PipelineOptions options = PipelineOptionsFactory.fromArgs(args).withValidation().create();
        Pipeline p = Pipeline.create(options);

        PCollection<String> input = p.apply("ReadTickets", PubsubIO.readStrings()
                                            .fromSubscription("projects/your-gcp-project/subscriptions/tickets-subscription"));
        
        PCollection<String> validatedTickets = input.apply("ValidateTickets", ParDo.of(new ValidateAndTransformTicketFn()));

        validatedTickets.apply("WriteToBigQuery", BigQueryIO.<String>write()
            .to("your_project:your_dataset.tickets")
            .withSchema("UUID:STRING, CustomerNumber:STRING, DrawDate:DATE, PurchaseDate:DATE, PrizeCollectionDate:DATE")
            .withFormatFunction((String ticket) -> {
                String[] parts = ticket.split(",");
                return new TableRow()
                    .set("UUID", parts[0])
                    .set("CustomerNumber", parts[1])
                    .set("DrawDate", parts[2])
                    .set("PurchaseDate", parts[3])
                    .set("PrizeCollectionDate", parts[4]);
            }));

        p.run().waitUntilFinish();
    }
}
