package features.javamethods;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueResponse;

import java.time.Instant;
import java.time.ZoneId;
import java.util.Map;

public class ReusableMethods {

    private static final Logger log = LoggerFactory.getLogger(ReusableMethods.class);

    // Fetch a specific secret from AWS Secrets Manager
    public static String getAwsSecret(String secretsPath, String key) {
        var awsSecrets = getAwsSecrets(secretsPath);
        return awsSecrets.get(key);
    }

    // Fetch all secrets from AWS Secrets Manager
    public static Map<String, String> getAwsSecrets(String secretsName) {
        log.info("Loading AWS secrets from {}...", secretsName);

        Map<String, String> map = null;
        try (var secretsClient = SecretsManagerClient.builder()
                .region(Region.US_EAST_1)
                .build()) {

            var valueRequest = GetSecretValueRequest.builder()
                    .secretId(secretsName)
                    .build();

            var valueResponse = secretsClient.getSecretValue(valueRequest);
            var json = valueResponse.secretString();
            if (json != null) {
                var mapper = new ObjectMapper();
                map = mapper.readValue(json, new TypeReference<Map<String, String>>() {});
            }

            if (map == null) {
                log.warn("Unable to load AWS secrets for {}", secretsName);
            }

        } catch (Exception e) {
            log.error("Error loading AWS secrets for {}", secretsName, e);
        }

        if (map == null) {
            log.error("Exiting due to failure to load secrets.");
            System.exit(-1);
        }

        return map;
    }

    // Get the timezone offset based on the system's default zone
    public static String getOffsetTimezone() {
        var defaultZoneId = ZoneId.systemDefault();

        // Handle common cases directly
        if ("America/Los_Angeles".equalsIgnoreCase(defaultZoneId.toString())) {
            return defaultZoneId.getRules().isDaylightSavings(Instant.now()) ? "-420" : "-480";
        } else if ("America/New_York".equalsIgnoreCase(defaultZoneId.toString())) {
            return defaultZoneId.getRules().isDaylightSavings(Instant.now()) ? "-240" : "-300";
        } else if ("America/Chicago".equalsIgnoreCase(defaultZoneId.toString())) {
            return defaultZoneId.getRules().isDaylightSavings(Instant.now()) ? "-300" : "-360";
        } else if ("UTC".equalsIgnoreCase(defaultZoneId.toString())) {
            return "0";
        } else {
            return "-300";  // Default to CST if unknown
        }
    }

    // Decrypt a JWT token and return the payload as a JSON string
    public static String decryptJwt(String token) {
        var decoder = java.util.Base64.getUrlDecoder();
        var parts = token.split("\\.");
        var payloadJson = new String(decoder.decode(parts[1]));
        return payloadJson;
    }
}
