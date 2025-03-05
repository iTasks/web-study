package com.example.bigtabledemo;

import com.google.cloud.bigtable.data.v2.BigtableDataClient;
import com.google.cloud.bigtable.data.v2.models.Query;
import com.google.cloud.bigtable.data.v2.models.Row;
import com.google.cloud.bigtable.data.v2.models.RowMutation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.time.Instant;

@SpringBootApplication
public class BigtableApplication {

    public static void main(String[] args) {
        SpringApplication.run(BigtableApplication.class, args);
    }

    @RestController
    static class TicketController {

        @Autowired
        private BigtableService bigtableService;

        @PostMapping("/tickets/{id}")
        public String createTicket(@PathVariable String id) {
            bigtableService.saveTicket(id);
            return "Ticket created with ID: " + id;
        }

        @GetMapping("/tickets/{id}")
        public String getTicket(@PathVariable String id) {
            return bigtableService.getTicket(id);
        }

    }

    @Service
    static class BigtableService {
        
        private BigtableDataClient dataClient;
        private String activeTable = "active-tickets";
        private String archiveTable = "archived-tickets";

        public BigtableService(@Value("${bigtable.project-id}") String projectId,
                               @Value("${bigtable.instance-id}") String instanceId) throws IOException {
            dataClient = BigtableDataClient.create(projectId, instanceId);
        }

        public void saveTicket(String ticketId) {
            RowMutation mutation = RowMutation.create(activeTable, ticketId)
                    .setCell("metadata", "creationTime", Instant.now().toEpochMilli());
            dataClient.mutateRow(mutation);
        }

        public String getTicket(String ticketId) {
            Row row = dataClient.readRow(activeTable, ticketId);
            if (row != null) {
                return "Ticket ID: " + ticketId + " Retrieved Successfully.";
            }
            return "Ticket not found.";
        }

        public void archiveTicket() {
            Query query = Query.create(activeTable).range("metadata", "creationTime", null, Instant.now().minusSeconds(3600).toEpochMilli());
            dataClient.readRows(query).forEach(row -> {
                String ticketId = row.getKey().toStringUtf8();
                // Archive the ticket
                RowMutation mutation = RowMutation.create(archiveTable, ticketId)
                        .setCell("metadata", "archiveTime", Instant.now().toEpochMilli());
                dataClient.mutateRow(mutation);
                // Delete from active table
                RowMutation deleteMutation = RowMutation.create(activeTable, ticketId);
                dataClient.mutateRow(deleteMutation);
            });
        }
    }

}
