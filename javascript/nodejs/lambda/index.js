const jwt = require("jsonwebtoken");
const jwksClient = require("jwks-rsa");

// Keycloak Realm Configuration – Update with your settings
const keycloakConfig = {
  /**
   * URL of the Keycloak realm issuer.
   * Example: https://<keycloak-domain>/realms/<realm-name>
   */
  issuer: "https://<keycloak-domain>/realms/<realm-name>",

  /**
   * Client ID registered in Keycloak.
   * Example: my-client-id
   */
  audience: "<client-id>",

  /**
   * JWKS (JSON Web Key Set) URI for verifying RS256 tokens.
   * Example: https://<keycloak-domain>/realms/<realm-name>/protocol/openid-connect/certs
   */
  jwksUri: "https://<keycloak-domain>/realms/<realm-name>/protocol/openid-connect/certs",
};

// Setup JWKS Client
const client = jwksClient({
  jwksUri: keycloakConfig.jwksUri,
});

/**
 * Retrieves the public signing key from the JWKS endpoint.
 * @param {Object} header - The header of the JWT containing the Key ID (kid).
 * @param {Function} callback - Callback function to return the signing key.
 */
function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    if (err) {
      callback(err, null);
    } else {
      const signingKey = key.publicKey || key.rsaPublicKey;
      callback(null, signingKey);
    }
  });
}

/**
 * AWS Lambda function to validate JWT tokens issued by Keycloak.
 * @param {Object} event - AWS Lambda event object, representing the HTTP request.
 * @param {Object} event.headers - The headers from the HTTP request (Authorization expected).
 * @returns {Promise<Object>} A response object containing the validation result or error details.
 * @example
 * // Expected Input:
 * // {
 * //   headers: {
 * //     Authorization: "Bearer <jwt-token>"
 * //   }
 * // }
 * // Expected Output for valid token:
 * // {
 * //   statusCode: 200,
 * //   body: "{\"message\":\"Token is valid\",\"user\":{\"sub\":\"1234abcd\",\"name\":\"John Doe\"}}"
 * // }
 */
exports.handler = async (event) => {
  try {
    /**
     * Step 1: Extract the Authorization header.
     */
    const authHeader = event.headers.Authorization || event.headers.authorization;
    if (!authHeader) {
      return {
        statusCode: 401,
        body: JSON.stringify({ message: "Unauthorized: Missing Authorization header" }),
      };
    }

    /**
     * Step 2: Extract JWT token from the Authorization header.
     * Expected format: "Bearer <jwt-token>".
     */
    const token = authHeader.split(" ")[1];
    if (!token) {
      return {
        statusCode: 401,
        body: JSON.stringify({ message: "Malformed Authorization header" }),
      };
    }

    /**
     * Step 3: Verify the JWT token using Keycloak configuration.
     */
    const verified = await new Promise((resolve, reject) => {
      jwt.verify(
        token,
        getKey, // Callback to fetch the signing key dynamically from the JWKS endpoint
        {
          algorithms: ["RS256"], // Validate the token signing algorithm
          issuer: keycloakConfig.issuer, // Validate the issuer claim
          audience: keycloakConfig.audience, // Validate the audience claim
        },
        (err, decoded) => {
          if (err) reject(err); // Reject if token verification fails
          resolve(decoded); // Return decoded token payload if successful
        }
      );
    });

    /**
     * Step 4: Respond with the decoded token payload.
     */
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Token is valid",
        user: verified, // Decoded JWT payload, typically includes claims like sub, email, roles, etc.
      }),
    };
  } catch (error) {
    console.error("JWT Verification Error:", error.message);

    /**
     * Return error response for invalid or expired tokens.
     */
    return {
      statusCode: 401,
      body: JSON.stringify({
        message: "Invalid or expired token",
        error: error.message,
      }),
    };
  }
};
