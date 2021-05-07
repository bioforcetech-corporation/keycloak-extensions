package com.zonaut.keycloak.extensions.mail;

import java.lang.*;
import java.util.*;
import org.jboss.logging.Logger;
import org.keycloak.Config.Scope;
import org.keycloak.email.EmailSenderProvider;
import org.keycloak.email.EmailSenderProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

import com.amazonaws.auth.EnvironmentVariableCredentialsProvider;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailService;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClientBuilder;

public class SESEmailSenderProviderFactory implements EmailSenderProviderFactory {

  private static final Logger log = Logger.getLogger("org.keycloak.events");

  private static AmazonSimpleEmailService sesClientInstance;

  @Override
  public EmailSenderProvider create(KeycloakSession session) {
    //using singleton pattern to avoid creating the client each time create is called
    if (sesClientInstance == null) {
      // Map<String, String> env = System.getenv();
      // for (String envName : env.keySet()) {
      //   log.info(envName + " = " + env.get(envName));
      // }
      String awsRegion = Objects.requireNonNull(System.getenv("AWS_DEFAULT_REGION"));

      sesClientInstance =
          AmazonSimpleEmailServiceClientBuilder
              .standard()
              .withCredentials(new EnvironmentVariableCredentialsProvider())
              .withRegion(awsRegion)
              .build();
    }

    return new SESEmailSenderProvider(sesClientInstance);
  }

  @Override
  public void init(Scope config) {
    
  }

  @Override
  public void postInit(KeycloakSessionFactory factory) { }

  @Override
  public void close() {
  }

  @Override
  public String getId() {
    // this way, using "default", will replace the default provider.
    // So you can set config variables (e.g. From display name) in Realm -> Mail settings
    return "default";
  }
}
