package com.zonaut.keycloak.extensions.events.logging;

import static javax.ws.rs.core.HttpHeaders.CONTENT_TYPE;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.http.HttpClient;
// import java.net.http.HttpHeaders;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublisher;
import java.time.Duration;
import org.jboss.logging.Logger;
import org.keycloak.models.AbstractKeycloakTransaction;
import org.keycloak.utils.MediaType;

public class UserVerifiedTransaction extends AbstractKeycloakTransaction {

  private static final Logger log = Logger.getLogger(UserVerifiedTransaction.class);

  private static final HttpClient HTTP_CLIENT = HttpClient.newBuilder().version(HttpClient.Version.HTTP_2)
      .connectTimeout(Duration.ofSeconds(5)).build();

  private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

  private final UserUuidDto userUuidDto;

  public UserVerifiedTransaction(UserUuidDto userUuidDto) {
    this.userUuidDto = userUuidDto;
  }

  @Override
  protected void commitImpl() {
    // log.info("## USER VERIFIED TRANSACTION");
    // log.info("-----------------------------------------------------------");
    // log.info(this.userUuidDto.toString());
    // log.info("-----------------------------------------------------------");

    // You could make a http call here and send the object.
    // When we throw an exception here, the user would not be verified when using
    // .enlistPrepare
    // throw new RuntimeException("External call failed!");

    try {
      BodyPublisher bp = HttpRequest.BodyPublishers.ofString(OBJECT_MAPPER.writeValueAsString(this.userUuidDto));

      // log.info("## REQUEST BODY");
      // log.info("-----------------------------------------------------------");
      // log.info(bp);
      // log.info("-----------------------------------------------------------");

      HttpRequest request = HttpRequest.newBuilder().POST(bp).uri(URI.create("https://api.plexus-automation.com/users"))
          .header(CONTENT_TYPE, MediaType.APPLICATION_JSON).header("X-Keycloak-Key", "asdQWE123-allow-user-creation").build();

      HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());

      // log.info("#### STATUS CODE");
      // log.info(response.statusCode());
      if (response.statusCode() >= 300) {
        log.error("UserVerifiedTransaction API call => UNEXPECTED RESPONSE STATUS CODE: " + response.statusCode());
        log.error("Body: " + bp);
        throw new RuntimeException("# UNEXPECTED RESPONSE STATUS CODE: " + response.statusCode());
      }

      // log.info("### USER VERIFIED TRANSACTION SUCCESS");

      // log.info("#### HEADERS");
      // HttpHeaders headers = response.headers();
      // headers.map().forEach((k, v) -> log.info("##### " + k + ":" + v));

      // log.info("#### RESPONSE BODY");
      // log.info(response.body());

    } catch (Exception e) {
      throw new RuntimeException("# USER VERIFIED TRANSACTION FAILED!", e);
    }
  }

  @Override
  protected void rollbackImpl() {
    //
  }

}
