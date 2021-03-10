# Requirements

Install on MacOSx brew and java11.

[How to here](https://devqa.io/brew-install-java/)

Remember to add the lines both in ~/.bash_profile and ~/.zshrc

``` sh
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
# default to Java 11
java11
```

### Production Apache permissions

``` sh
sudo usermod -a -G keycloak ubuntu
sudo chown -R keycloak:keycloak /opt/keycloak/
sudo find /opt/keycloak/ -type f -exec chmod 664 {} \;
sudo find /opt/keycloak/ -type d -exec chmod 775 {} \;
```

# Keycloak extensions

Keycloak extension examples.

* [provider-domain](provider-domain/README.md) *
  * example of adding new domain entities  
* [spi-event-listener](spi-event-listener/README.md) *
  * example of a custom event listener
* [spi-mail-template-override](spi-mail-template-override/README.md) *
  * example on how to change default mail behaviour and add extra variables to it.
* [spi-registration-profile](spi-registration-profile/README.md)
  * disable first and last name validation in the registration page
* [spi-resource](spi-resource/README.md) *
  * example of a custom REST resource
* [theme-minimal](theme-minimal/README.md) *
  * a custom theme with minimal changes

## Deploy on server

```
cd /opt/keycloak/standalone/deployments
copy here the .jar file (built file in /spi-xxxxx/target/xxxx.jar) moving out the older version of the .jar
```

Open Keycloak Admin Console [link](https://auth.plexus-automation.com/auth)
Go to Manage -> Events -> Config
Under "Event Listeners" you may add your event listener (default name is "pl_event_listener")


## Build

- Increase versioning in related /spi-xxxxx/pom.xml

- Build all

``` sh
./mvnw clean install
```

- Or Build single module

``` sh
./mvnw clean install -pl provider-domain
./mvnw clean install -pl spi-event-listener
./mvnw clean install -pl spi-mail-template-override
./mvnw clean install -pl spi-registration-profile
./mvnw clean install -pl spi-resource
./mvnw clean install -pl theme-minimal
```

## Run with Docker Compose

## Other resources

Don't forget to look in the actual Keycloak code itself because the examples are based on the implementations itself.

* https://github.com/keycloak
* https://github.com/keycloak/keycloak/tree/master/examples
* https://www.keycloak.org/docs/latest/server_development/
* https://github.com/thomasdarimont/keycloak-extension-playground
