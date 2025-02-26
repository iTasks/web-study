package com.example.chatbot;

import com.google.cloud.dialogflow.v2.QueryResult;
import com.google.cloud.dialogflow.v2.SessionsClient;
import com.google.cloud.dialogflow.v2.TextInput;
import com.google.cloud.dialogflow.v2.TextInput.Builder;
import com.google.cloud.dialogflow.v2.DetectIntentRequest;
import com.google.cloud.dialogflow.v2.DetectIntentResponse;
import com.google.cloud.dialogflow.v2.QueryInput;
import com.google.cloud.dialogflow.v2.SessionName;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * ChatbotServlet is a simple servlet that interfaces with Google Cloud Dialogflow to provide chatbot responses.
 * This servlet is designed to be deployed on Google App Engine.
 */
public class ChatbotServlet extends HttpServlet {

    private static final String PROJECT_ID = "your-project-id";
    private static final String SESSION_ID = "your-session-id";

    /**
     * Handles GET requests and responds with chatbot's response.
     *
     * @param req  the HttpServletRequest object that contains the request the client has made of the servlet
     * @param resp the HttpServletResponse object that contains the response the servlet sends to the client
     * @throws IOException if an input or output error occurs while the servlet is handling the GET request
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String userMessage = req.getParameter("message");
        if (userMessage == null || userMessage.isEmpty()) {
            resp.getWriter().println("Please provide a message parameter.");
            return;
        }

        String chatbotResponse = getChatbotResponse(userMessage);
        resp.setContentType("text/plain");
        resp.getWriter().println(chatbotResponse);
    }

    /**
     * Gets the chatbot's response using Google Cloud Dialogflow.
     *
     * @param message the user's message to the chatbot
     * @return the chatbot's response
     * @throws IOException if an input or output error occurs while communicating with Dialogflow
     */
    private String getChatbotResponse(String message) throws IOException {
        try (SessionsClient sessionsClient = SessionsClient.create()) {
            SessionName session = SessionName.of(PROJECT_ID, SESSION_ID);
            Builder textInput = TextInput.newBuilder().setText(message).setLanguageCode("en-US");
            QueryInput queryInput = QueryInput.newBuilder().setText(textInput).build();
            DetectIntentRequest detectIntentRequest = DetectIntentRequest.newBuilder()
                    .setSession(session.toString())
                    .setQueryInput(queryInput)
                    .build();

            DetectIntentResponse response = sessionsClient.detectIntent(detectIntentRequest);
            QueryResult queryResult = response.getQueryResult();
            return queryResult.getFulfillmentText();
        }
    }
}
