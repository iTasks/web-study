# Chatbot App

## Diagram:
```
+-----------------------+
|                       |
|    Client (User)      |
|                       |
+----------+------------+
           |
           v
+----------+------------+
|                       |
|      HTTP Request     |
|  (message parameter)  |
|                       |
+----------+------------+
           |
           v
+----------+------------+
|                       |
|  Google App Engine    |
|                       |
|  +-----------------+  |
|  |                 |  |
|  |  ChatbotServlet |  |  <-- Java servlet that handles HTTP requests
|  |                 |  |
|  +--------+--------+  |
|           |            |
|           v            |
|  +--------+--------+  |
|  |                 |  |
|  |   Dialogflow    |  |  <-- Google Cloud Dialogflow API
|  |                 |  |
|  +--------+--------+  |
|           |            |
|           v            |
|  +--------+--------+  |
|  |                 |  |
|  |  Query Result   |  |  <-- Response from Dialogflow
|  |                 |  |
|  +--------+--------+  |
|           |            |
|           v            |
|  +--------+--------+  |
|  |                 |  |
|  |  HTTP Response  |  |  <-- Chatbot's response sent back to client
|  |                 |  |
|  +-----------------+  |
|                       |
+-----------------------+
```


## Running the Chatbot:

1. **Set Up Google Cloud Project:**
   - Create a Google Cloud project.
   - Enable the Dialogflow API.
   - Create and configure a Dialogflow agent.

2. **Configure the ChatbotServlet:**
   - Replace `your-project-id` and `your-session-id` in the `ChatbotServlet` class with your actual project ID and session ID.

3. **Run Locally:**
   - Use a local server such as Apache Tomcat to deploy the servlet.
   - Access the servlet via `http://localhost:8080/chatbot?message=Hello`.

## Deploying the Chatbot:

1. **Google App Engine Deployment:**
   - Create an `app.yaml` configuration file for App Engine.
   - Deploy the application using the following command:
     ```sh
     gcloud app deploy
     ```

2. **Access the Deployed Chatbot:**
   - Access the deployed servlet via the URL provided by Google App Engine, e.g., `https://<your-project-id>.appspot.com/chatbot?message=Hello`.


