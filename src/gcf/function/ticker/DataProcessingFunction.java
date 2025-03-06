import com.google.api.core.ApiFuture;
import com.google.api.core.ApiFutures;
import com.google.api.gax.rpc.ApiException;
import com.google.cloud.functions.HttpFunction;
import com.google.cloud.functions.HttpRequest;
import com.google.cloud.functions.HttpResponse;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.TopicName;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.ProcessFunction;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

public class DataProcessingFunction implements HttpFunction {

    private static final String PROJECT_ID = "your-gcp-project-id";
    private static final String TOPIC_ID = "data-processing-topic";
    private static final String SUBSCRIPTION_ID = "data-processing-subscription";

    public static void main(String[] args) {
        deployDataflowPipeline();
    }
    
    private static void deployDataflowPipeline() {
        PipelineOptions options = PipelineOptionsFactory.create();
        Pipeline p = Pipeline.create(options);
        
        p.apply("ReadFromPubSub", 
                PubsubIO.readStrings().fromSubscription(String.format("projects/%s/subscriptions/%s", PROJECT_ID, SUBSCRIPTION_ID)))
         .apply("ProcessData", 
                ParDo.of(new DoFn<String, String>() {
                    @ProcessElement
                    public void processElement(ProcessContext c) {
                        // processing logic here
                        c.output(c.element().toUpperCase());
                    }
                }))
         .apply("WriteToGCS", 
                TextIO.write().to("gs://your-bucket/results/output"));
        
        p.run().waitUntilFinish();
    }

    @Override
    public void service(HttpRequest request, HttpResponse response) throws IOException {
        Publisher publisher = null;
        try {
            TopicName topicName = TopicName.of(PROJECT_ID, TOPIC_ID);
            publisher = Publisher.newBuilder(topicName).build();
            
            String message = "Trigger Dataflow Job";
            ByteString data = ByteString.copyFromUtf8(message);
            PubsubMessage pubsubMessage = PubsubMessage.newBuilder().setData(data).build();
            
            ApiFuture<String> future = publisher.publish(pubsubMessage);
            future.get(); // Blocking call to ensure message is published
            
            BufferedWriter writer = response.getWriter();
            writer.write("Message published");
        } catch (InterruptedException | ExecutionException | ApiException e) {
            throw new IOException("Error publishing Pub/Sub message: " + e.getMessage(), e);
        } finally {
            if (publisher != null) {
                publisher.shutdown();
            }
        }
    }
}
