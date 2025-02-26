## Chatbot

### Diagram:
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
