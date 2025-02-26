from flask import Flask, request, jsonify
from google.cloud import dialogflow_v2 as dialogflow

app = Flask(__name__)

PROJECT_ID = 'your-project-id'
SESSION_ID = 'your-session-id'

@app.route('/chatbot', methods=['GET'])
def chatbot():
    user_message = request.args.get('message')
    if not user_message:
        return jsonify({'response': 'Please provide a message parameter.'})

    response_text = get_chatbot_response(user_message)
    return jsonify({'response': response_text})

def get_chatbot_response(message):
    session_client = dialogflow.SessionsClient()
    session = dialogflow.SessionsClient.session_path(PROJECT_ID, SESSION_ID)
    
    text_input = dialogflow.TextInput(text=message, language_code='en-US')
    query_input = dialogflow.QueryInput(text=text_input)
    
    response = session_client.detect_intent(request={'session': session, 'query_input': query_input})
    return response.query_result.fulfillment_text

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
