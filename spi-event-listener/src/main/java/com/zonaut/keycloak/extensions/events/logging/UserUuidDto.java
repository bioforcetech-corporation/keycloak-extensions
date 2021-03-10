package com.zonaut.keycloak.extensions.events.logging;

public class UserUuidDto {

  private String type;
  private String uuid;
  private String email;
  private String firstname;
  private String lastname;

  public UserUuidDto(String type, String uuid, String email, String firstname, String lastname) {
    this.type = type;
    this.uuid = uuid;
    this.email = email;
    this.firstname = firstname;
    this.lastname = lastname;
  }

  public String getType() {
    return type;
  }

  public String getUuid() {
    return uuid;
  }

  public String getEmail() {
    return email;
  }

  public String getFirstname() {
    return firstname;
  }

  public String getLastname() {
    return lastname;
  }

  @Override
  public String toString() {
    return "UserUuidDto{" + "type='" + type + '\'' + ", uuid='" + uuid + '\'' + ", email='" + email + '\''
        + ", firstname='" + firstname + '\'' + ", lastname='" + lastname + '\'' + '}';
  }

}
