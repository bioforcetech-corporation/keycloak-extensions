package com.zonaut.keycloak.extensions.mail;

import java.util.Map;
import org.jboss.logging.Logger;
import org.keycloak.email.EmailSenderProvider;
import org.keycloak.models.UserModel;

import com.amazonaws.services.simpleemail.AmazonSimpleEmailService;
import com.amazonaws.services.simpleemail.model.Body;
import com.amazonaws.services.simpleemail.model.Content;
import com.amazonaws.services.simpleemail.model.Destination;
import com.amazonaws.services.simpleemail.model.Message;
import com.amazonaws.services.simpleemail.model.SendEmailRequest;

public class SESEmailSenderProvider implements EmailSenderProvider {

  private static final Logger log = Logger.getLogger("org.keycloak.events");

  private final AmazonSimpleEmailService sesClient;

  public SESEmailSenderProvider(
      AmazonSimpleEmailService sesClient) {
    this.sesClient = sesClient;
  }

  @Override
  public void send(Map<String, String> config, UserModel user, String subject, String textBody,
      String htmlBody) {
      // for (String configName : config.keySet()) {
      //   log.info(configName + " = " + config.get(configName));
      // }

      Message message = new Message().withSubject(new Content().withData(subject))
          .withBody(new Body().withHtml(new Content().withData(htmlBody))
              .withText(new Content().withData(textBody).withCharset("UTF-8")));

      SendEmailRequest sendEmailRequest = new SendEmailRequest()
          .withSource(config.get("fromDisplayName") + "<" + config.get("from") + ">")
          .withMessage(message).withDestination(new Destination().withToAddresses(user.getEmail()));

      sesClient.sendEmail(sendEmailRequest);
      // log.info("email sent to " + user.getEmail() + " successfully");
  }

  @Override
  public void close() {

  }
}
