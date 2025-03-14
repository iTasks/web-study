import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

import com.auth0.jwk.*;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;

import java.util.Map;

/**
 * Lambda function for validating JWT tokens issued by Keycloak.
 * 
 * This function dynamically fetches public keys (JWKS) from Keycloak's JWKS URI to
 * verify the signature of RS256-signed tokens. The function also validates key claims
 * such as `issuer` and `audience` to ensure token validity.
 * 
 * Build and Deployment Instructions:
 * -----------------------------------
 * 1. Add the required dependencies in your `pom.xml` (if using Maven) or `build.gradle` (Gradle):
 *    - auth0: JSON Web Token (JWT) library for token decoding and verification.
 * 
 *    Maven Dependency:
 *    <dependency>
 *        <groupId>com.auth0</groupId>
 *        <artifactId>java-jwt</artifactId>
 *        <version>4.3.0</version>
 *    </dependency>
 *    <dependency>
 *        <groupId>com.auth0</groupId>
 *        <artifactId>jwks-rsa</artifactId>
 *        <version>0.20.0</version>
 *    </dependency>
 * 
 * 2. Package the Java file into a JAR using Maven or Gradle.
 * 
 *    Maven Command:
 *    mvn clean install
 * 
 *    Gradle Command:
 *    gradle build
 * 
 * 3. Deploy the JAR to AWS Lambda.
 *    During deployment, select this class's handler: `LambdaFunction::handleRequest`.
 */
public class LambdaFunction implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    private static final String KEYCLOAK_ISSUER = "https://<keycloak-domain>/realms/<realm-name>";
    private static final String KEYCLOAK_CLIENT_ID = "<client-id>";
    private static final String KEYCLOAK_JWKS_URI = "https://<keycloak-domain>/realms/<realm-name>/protocol/openid-connect/certs";

    /**
     * AWS Lambda Handler function to validate a JWT token issued by Keycloak.
     * 
     * @param request The incoming API Gateway Proxy Request containing headers, body, etc.
     * @param context The AWS Lambda context object containing runtime information.
     * @return APIGatewayProxyResponseEvent Response containing token validation result.
     */
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
        try {
            // Extract Authorization header
            Map<String, String> headers = request.getHeaders();
            if (headers == null || !headers.containsKey("Authorization")) {
                return createResponse(401, "Unauthorized: Missing Authorization header");
            }

            String authHeader = headers.get("Authorization");
            if (!authHeader.startsWith("Bearer ")) {
                return createResponse(401, "Malformed Authorization header");
            }

            String token = authHeader.substring(7); // Remove "Bearer " from the Header

            // Validate the JWT and decode its payload
            DecodedJWT decodedJWT = validateJwt(token);

            // If successful, respond with decoded token claims
            return createResponse(200, String.format("Token is valid. Claims: %s", decodedJWT.getClaims()));

        } catch (Exception e) {
            // Handle any validation or runtime error
            return createResponse(401, String.format("Invalid or expired token: %s", e.getMessage()));
        }
    }

    /**
     * Validates the given JWT token using Keycloak's JWKS URI and Keycloak configuration.
     * 
     * @param token The JWT token string to validate.
     * @return DecodedJWT The decoded JWT object, containing payload claims.
     * @throws Exception If the token is invalid, expired, or cannot be verified.
     */
    private DecodedJWT validateJwt(String token) throws Exception {
        try {
            // Create JWKS client loading keys from the Keycloak JWKS URI
            JwkProvider jwkProvider = new UrlJwkProvider(KEYCLOAK_JWKS_URI);

            // Decode the token's header to extract `kid` (Key ID)
            DecodedJWT jwt = JWT.decode(token);
            String kid = jwt.getKeyId();

            // Fetch the public key matching the `kid`
            Jwk jwk = jwkProvider.get(kid);
            Algorithm algorithm = Algorithm.RSA256((java.security.interfaces.RSAPublicKey) jwk.getPublicKey(), null);

            // Validate the token's signature and claims
            JWTVerifier verifier = JWT.require(algorithm)
                .withIssuer(KEYCLOAK_ISSUER) // Validate the Keycloak realm's issuer
                .withAudience(KEYCLOAK_CLIENT_ID) // Validate the audience for your client ID
                .build();

            // Return the decoded JWT if valid
            return verifier.verify(token);

        } catch (JwkException | JWTVerificationException e) {
            throw new Exception("JWT validation failed: " + e.getMessage());
        }
    }

    /**
     * Utility method to create a response for API Gateway.
     * 
     * @param statusCode The HTTP status code of the response.
     * @param message The body message of the response.
     * @return APIGatewayProxyResponseEvent The response object for API Gateway.
     */
    private APIGatewayProxyResponseEvent createResponse(int statusCode, String message) {
        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
        response.setStatusCode(statusCode);
        response.setBody(String.format("{\"message\": \"%s\"}", message));
        return response;
    }
}
