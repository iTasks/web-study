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
    
    :param token: The JWT token from the Authorization header.
    :type token: str
    :return: Decoded token payload if the token is valid.
    :rtype: dict
    :raises: Exception if the token is invalid.
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
    
    :param event: The AWS Lambda event object containing the HTTP request details.
    :type event: dict
    :param context: The AWS Lambda context object.
    :type context: object
    :return: A response object for the HTTP request.
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
