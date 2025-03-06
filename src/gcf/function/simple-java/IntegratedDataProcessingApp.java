import com.google.cloud.bigtable.data.v2.BigtableDataClient;
import com.google.cloud.bigtable.data.v2.models.RowMutation;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.ProcessFunction;
import org.apache.beam.sdk.values.PCollection;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.Encoders;

public class IntegratedDataProcessingApp {
    private static final String PROJECT_ID = "your-project-id";
    private static final String INSTANCE_ID = "your-instance-id";
    private static final String TABLE_NAME = "active-tickets";

    public static void main(String[] args) {
        processWithSpark();
        processWithBeam();
    }

    private static void processWithSpark() {
        SparkSession spark = SparkSession.builder()
            .appName("Spark Bigtable Data Processor")
            .master("local[*]")
            .getOrCreate();

        String pathToJson = "path_to_some_json_data.json";
		Dataset<Row> df = spark.read().json(pathToJson);

        // Assumed transformation
        Dataset<String> ticketIds = df.select("ticketId").as(Encoders.STRING());

        // Here we would typically do further data processing
        ticketIds.foreachPartition(iterator -> {
            try (BigtableDataClient client = BigtableDataClient.create(PROJECT_ID, INSTANCE_ID)) {
                while (iterator.hasNext()) {
                    String ticketId = iterator.next();
                    writeToBigtable(client, ticketId);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });

        spark.stop();
    }

    private static void writeToBigtable(BigtableDataClient client, String ticketId) {
        RowMutation mutation = RowMutation.create(TABLE_NAME, ticketId)
                .setCell("metadata", "processedTime", System.currentTimeMillis());
        client.mutateRow(mutation);
    }

    private static void processWithBeam() {
        Pipeline pipeline = Pipeline.create();

        PCollection<String> inputCollection = pipeline.apply(Create.of("Ticket1", "Ticket2", "Ticket3"));

        PCollection<String> processedTickets = inputCollection.apply("Process Tickets", ParDo.of(new DoFn<String, String>() {
            @ProcessElement
            public void processElement(@Element String ticketId, OutputReceiver<String> out) {
                // Simulate processing
                out.output(ticketId + " processed");
            }
        }));

        // Additional steps as required, like aggregation, combination, etc.
        pipeline.run().waitUntilFinish();
    }
}
