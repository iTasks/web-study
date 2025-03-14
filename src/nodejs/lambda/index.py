import json
import requests
from jose import jwt, JWTError

# Keycloak Realm Configuration – Update with your settings
KEYCLOAK_ISSUER = "https://<keycloak-domain>/realms/<realm-name>"  # Replace with your Keycloak realm URL
KEYCLOAK_CLIENT_ID = "<client-id>"  # Replace with your client ID from Keycloak
JWKS_URI = f"{KEYCLOAK_ISSUER}/protocol/openid-connect/certs"  # JWKS endpoint for public keys

def fetch_jwks():
    """
    Fetch the JSON Web Key Set (JWKS) from the Keycloak JWKS endpoint.

    The JWKS keys are dynamically fetched from the Keycloak server to validate the
    RS256-signed JWT tokens. This ensures compatibility with Keycloak key rotations.

    :return: A dictionary containing the JWKS keys.
    :rtype: dict
    :raises: requests.RequestException if the JWKS endpoint fails.
    """
    try:
        response = requests.get(JWKS_URI)
        response.raise_for_status()  # Raise an error for HTTP failures
        return response.json()
    except requests.RequestException as e:
        raise Exception(f"Failed to fetch JWKS keys: {e}")


def validate_jwt(token):
    """
    Validate the JWT token using Keycloak's JWKS endpoint.

    This function retrieves the JWKS keys from the Keycloak server, validates the JWT
    token's signature using the matching public key, and ensures that the token's
    claims (issuer, audience) are correct.

    :param token: The JWT token from the Authorization header.
    :type token: str
    :return: Decoded token payload (dict) if the token is valid.
    :rtype: dict
    :raises: Exception if the token is invalid or expired.
    """
    try:
        # Fetch JWKS keys dynamically
        jwks = fetch_jwks()
        
        # Extract the 'kid' (Key ID) from the token header
        unverified_header = jwt.get_unverified_header(token)
        kid = unverified_header.get("kid")
        if not kid:
            raise Exception("Token does not contain a 'kid' in its header.")
        
        # Find the public key matching the 'kid'
        key = next((key for key in jwks["keys"] if key["kid"] == kid), None)
        if not key:
            raise Exception("No matching key found for 'kid' in JWKS.")
        
        # Public key for RSA verification
        rsa_public_key = jwt.construct_rsa_key(key)
        
        # Validate the token
        decoded_token = jwt.decode(
            token,
            rsa_public_key,
            algorithms=["RS256"],  # Keycloak tokens are typically signed with RS256
            issuer=KEYCLOAK_ISSUER,
            audience=KEYCLOAK_CLIENT_ID,
        )
        
        return decoded_token
    
    except JWTError as e:
        raise Exception(f"Invalid or expired token: {e}")
        

def lambda_handler(event, context):
    """
    AWS Lambda function handler for validating JWT tokens issued by Keycloak.

    This function expects the incoming request to include an HTTP Authorization header
    with a Bearer token. If the token is valid, it returns a 200 response with the
    decoded token payload. If the token is invalid, expired, or missing, it returns a 401
    response with the error details.

    Deployment and Build Steps:
    ---------------------------
    1. Install Dependencies:
       - Install the required libraries locally using pip:
         ```
         pip install python-jose requests -t .
         ```
    
    2. Package the Function:
       - Include the `lambda_function.py` and all dependencies into a zip file:
         ```
         zip -r lambda-function.zip lambda_function.py .
         ```

    3. Deploy to AWS Lambda:
       - Go to the AWS Lambda console and upload the `lambda-function.zip`.

    Example Event Input:
    --------------------
    {
        "headers": {
            "Authorization": "Bearer <your-jwt-token>"
        }
    }

    :param event: The AWS Lambda event object (from API Gateway or other integrations).
                  Should include headers with an Authorization field containing the JWT.
    :type event: dict
    :param context: The AWS Lambda context object (not used in this function).
    :type context: object
    :return: A response object for the HTTP request (statusCode, body).
    :rtype: dict
    """
    try:
        # Extract Authorization header
        auth_header = event.get("headers", {}).get("Authorization") or event.get("headers", {}).get("authorization")
        if not auth_header:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": "Unauthorized: Missing Authorization header"}),
            }
        
        # Extract JWT token from header
        try:
            token = auth_header.split(" ")[1]  # Expected format: "Bearer <token>"
        except IndexError:
            return {
                "statusCode": 401,
                "body": json.dumps({"message": "Malformed Authorization header"}),
            }
        
        # Validate the token
        decoded_token = validate_jwt(token)
        
        # Return success response with decoded token info
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Token is valid", "user": decoded_token}),
        }
    
    except Exception as e:
        return {
            "statusCode": 401,
            "body": json.dumps({"message": "Invalid or expired token", "error": str(e)}),
        }


# Additional Information
"""
Build and Deployment Details:

1. **Dependencies**:
   - `python-jose`: Library for decoding and validating JSON Web Tokens (JWT).
   - `requests`: HTTP library for fetching JWKS keys from Keycloak's JWKS endpoint.

   Install these dependencies locally or in your project directory:
   pip install python-jose requests -t .

2. **Packaging**:
   - Ensure the `lambda_function.py` and the `site-packages` folder for dependencies are
     packaged into a single zip file before deploying to AWS Lambda.

   Command to create the zip package:
   zip -r lambda-function.zip lambda_function.py .

3. **Deployment**:
   - Upload the zip file (`lambda-function.zip`) to an AWS Lambda function using the AWS Console,
     AWS CLI, or IaC tools like AWS SAM or Terraform.

Example usage:
--------------
Event Input:
{
    "headers": {
        "Authorization": "Bearer <valid-jwt-token>"
    }
}

Expected Output (Valid Token):
{
    "statusCode": 200,
    "body": "{\"message\":\"Token is valid\", \"user\":{\"sub\":\"1234abcd\",\"email\":\"user@example.com\"}}"
}

Expected Output (Invalid Token or Errors):
{
    "statusCode": 401,
    "body": "{\"message\":\"Invalid or expired token\", \"error\":\"Signature verification failed\"}"
}
"""
