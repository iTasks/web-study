package com.example;

import io.micronaut.http.HttpResponse;
import io.micronaut.http.MediaType;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Post;
import io.micronaut.http.annotation.Produces;
import io.micronaut.http.annotation.Body;

@Controller("/data")
public class DataProcessingController {

    /**
     * Endpoint to simulate data processing.
     * In a real scenario, the method would interface with Cloud Pub/Sub or a Beam pipeline.
     */
    @Post("/process")
    @Produces(MediaType.TEXT_PLAIN)
    public HttpResponse<String> triggerDataPipeline(@Body String inputData) {
        try {
            System.out.println("Received data for processing: " + inputData);
            // Simulated data processing logic
            performDataProcessing(inputData);
            // In practice, you might want to asynchronously handle processing so you can respond to the request quickly
            return HttpResponse.ok("Data processing initiated.");
        } catch (Exception e) {
            return HttpResponse.serverError("Failed to initiate data processing due to: " + e.getMessage());
        }
    }

    /**
     * Simulated data processing method.
     * @param inputData Data received for processing
     */
    private void performDataProcessing(String inputData) {
        // This could be a place where you trigger an Apache Beam job or publish to a Google Cloud Pub/Sub topic.
        System.out.println("Processing data: " + inputData);
    }

    public static void main(String[] args) {
        io.micronaut.runtime.Micronaut.run(DataProcessingController.class, args);
    }
}
