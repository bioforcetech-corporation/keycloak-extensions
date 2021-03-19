# HOW TO SETUP EC2 Ubuntu instance + RDS MySql instance in same subnet, keeping RDS protected from public internet
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateVPC.html


# https://medium.com/@pratik.dandavate/setting-up-keycloak-standalone-with-mysql-database-7ebb614cc229
# From EC2 connect to mysql RDS instance via mysql-client cli
mysql -h cloud-test-mysql.cehuqqmfsvm0.us-west-2.rds.amazonaws.com -P 3306 -u admin -p

mysql > CREATE DATABASE keycloak DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
mysql > CREATE USER 'keycloak'@'%' IDENTIFIED WITH mysql_native_password BY 'Biochar#11!-keycloak';
mysql > GRANT ALL ON keycloak.* TO 'keycloak'@'%';
mysql > FLUSH PRIVILEGES;

# va scaricato il driver JDBC della esatta versione di MySql installata su RDS (nel mio caso 8.0.20, perché è quello che ho scelto x istanza RDS)
sudo /opt/keycloak/bin/jboss-cli.sh
# while in [disconnected /] mode enter:
module add --name=com.mysql --resources=/opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.20.jar --dependencies=javax.api,javax.transaction.api

sudo mkdir -p /opt/keycloak/modules/system/layers/keycloak/com/mysql/main
sudo nano /opt/keycloak/modules/system/layers/keycloak/com/mysql/main/module.xml
```
<?xml version="1.0" ?>
<!-- https://medium.com/@pratik.dandavate/setting-up-keycloak-standalone-with-mysql-database-7ebb614cc229 -->
<module xmlns="urn:jboss:module:1.3" name="com.mysql">
 <resources>
  <resource-root path="mysql-connector-java-8.0.20.jar" />
 </resources>
 <dependencies>
  <module name="javax.api"/>
  <module name="javax.transaction.api"/>
 </dependencies>
</module>
```

sudo nano /opt/keycloak/standalone/configuration/standalone.xml 
# datasource part must be updated to point to MySql instance, in our case on RDS endpoint
```
<datasource jndi-name="java:/jboss/datasources/KeycloakDS" pool-name="KeycloakDS" enabled="true">
  <connection-url>jdbc:mysql://HOST_MYSQL_URL:3306/keycloak?useSSL=false&amp;characterEncoding=UTF-8&amp;allowPublicKeyRetrieval=true</connection-url>
  <driver>mysql</driver>
  <pool>
    <min-pool-size>5</min-pool-size>
    <max-pool-size>15</max-pool-size>
  </pool>
  <security>
    <user-name>USER_HERE</user-name>
    <password>PASSWORD_HERE</password>
  </security>
  <validation>
    <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"/>
    <validate-on-match>true</validate-on-match>
    <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"/>
  </validation>
</datasource>
<drivers>
  <driver name="mysql" module="com.mysql">
    <driver-class>com.mysql.cj.jdbc.Driver</driver-class>
  </driver>
  <driver name="h2" module="com.h2database.h2">
    <xa-datasource-class>org.h2.jdbcx.JdbcDataSource</xa-datasource-class>
  </driver>
</drivers>
```

sudo /opt/keycloak/bin/add-user-keycloak.sh -u admin -r master
sudo systemctl restart keycloak.service

# questo finché sei in fase di test e non hai certificato per https
sudo /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin
sudo /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE

# error logs:
cat /opt/keycloak/standalone/log/server.log

# it is possible to remove all references to H2 embedded datasource now, from the xml configuration
sudo nano /opt/keycloak/standalone/configuration/standalone.xml
```
# comment out ExampleDS under <datasources>
# comment out driver name h2 under <drivers>
# under <subsystems>, modify line default-bindings where you find "java:jboss/datasources/ExampleDS", replace with "java:jboss/datasources/KeycloakDS" instead
```
