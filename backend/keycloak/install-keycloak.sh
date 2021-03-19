#!/bin/bash

# https://medium.com/@hasnat.saeed/setup-keycloak-server-on-ubuntu-18-04-ed8c7c79a2d9

sudo apt-get update
sudo apt-get install default-jdk -y

cd /opt
sudo wget https://github.com/keycloak/keycloak/releases/download/12.0.4/keycloak-12.0.4.tar.gz
sudo tar -xvzf keycloak-12.0.4.tar.gz
sudo mv keycloak-12.0.4 /opt/keycloak

sudo groupadd keycloak
sudo useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak
sudo chown -R keycloak: keycloak
sudo chmod o+x /opt/keycloak/bin/

cd /etc/
sudo mkdir keycloak
sudo cp /opt/keycloak/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf
sudo cp /opt/keycloak/docs/contrib/scripts/systemd/launch.sh /opt/keycloak/bin/
sudo chown keycloak: /opt/keycloak/bin/launch.sh
sudo nano /opt/keycloak/bin/launch.sh
```
# riga 4 ->
    WILDFLY_HOME="/opt/keycloak"
```

sudo cp /opt/keycloak/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/keycloak.service
sudo nano /etc/systemd/system/keycloak.service
```
[Unit]
Description=Plexus Keycloak Server
After=syslog.target network.target
Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=keycloak
Group=keycloak
LimitNOFILE=102642
PIDFile=/var/run/keycloak/keycloak.pid
ExecStart=/opt/keycloak/bin/launch.sh $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND 
StandardOutput=null

[Install]
WantedBy=multi-user.target
```

cd /opt/keycloak/
# parte di HTTPS
sudo ./bin/jboss-cli.sh 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)'
sudo ./bin/jboss-cli.sh 'embed-server,/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=443)'
sudo ./bin/jboss-cli.sh 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)'


sudo systemctl daemon-reload
# sudo systemctl enable keycloak
sudo systemctl start keycloak
sudo systemctl status keycloak

sudo tail -f /opt/keycloak/standalone/log/server.log # check logs

cd /opt/keycloak/bin
sudo ./add-user-keycloak.sh -u admin -r master
# OUTPUT -> Added 'admin' to '/opt/keycloak/standalone/configuration/keycloak-add-user.json', restart server to load user

# setup management console (WildFly)
sudo nano /etc/keycloak/keycloak.conf
```
# The configuration you want to run
WILDFLY_CONFIG=standalone.xml
# The mode you want to run
WILDFLY_MODE=standalone
# The address to bind to
WILDFLY_BIND=0.0.0.0
# The address console to bind to
WILDFLY_MANAGEMENT_CONSOLE_BIND=0.0.0.0
```

sudo nano /opt/keycloak/bin/launch.sh
```
#!/bin/bash

if [ "x$WILDFLY_HOME" = "x" ]; then
    WILDFLY_HOME="/opt/keycloak"
fi

if [[ "$1" == "domain" ]]; then
    $WILDFLY_HOME/bin/domain.sh -c $2 -b $3 -bmanagement $4
else
    $WILDFLY_HOME/bin/standalone.sh -c $2 -b $3 -bmanagement $4
fi
```

sudo nano /etc/systemd/system/keycloak.service
```
[Unit]
Description=Plexus Keycloak Server
After=syslog.target network.target
Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=keycloak
Group=keycloak
LimitNOFILE=102642
PIDFile=/var/run/keycloak/keycloak.pid
ExecStart=/opt/keycloak/bin/launch.sh $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND $WILDFLY_MANAGEMENT_CONSOLE_BIND
StandardOutput=null     # comment if there are errors running the service. will log to "sudo journalctl -u keycloak.service -b"

[Install]
WantedBy=multi-user.target
```

sudo nano /opt/keycloak/standalone/configuration/standalone.xml
```
# interfaces block
<interfaces>
  <!-- ... -->
  <interface name="public">
    <inet-address value="${jboss.bind.address:0.0.0.0}"/>
  </interface>
</interfaces>
# ...
# server block
<server name="default-server">
  <http-listener name="default" socket-binding="http" proxy-address-forwarding="true" enable-http2="false" redirect-socket="proxy-https"/>
  <host name="default-host" alias="localhost">
    <location name="/" handler="welcome-content"/>
    <http-invoker security-realm="ApplicationRealm"/>
  </host>
</server>
# ...
# socket-binding-group block must be like this (if there's something to modify, you may have skipped a step before)
<socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:0}">
  <socket-binding name="ajp" port="${jboss.ajp.port:8009}"/>
  <socket-binding name="http" port="${jboss.http.port:8080}"/>
  <socket-binding name="https" port="${jboss.https.port:8443}"/>
  <socket-binding name="management-http" interface="management" port="${jboss.management.http.port:9990}"/>
  <socket-binding name="management-https" interface="management" port="${jboss.management.https.port:9993}"/>
  <socket-binding name="proxy-https" port="443"/>
  <socket-binding name="txn-recovery-environment" port="4712"/>
  <socket-binding name="txn-status-manager" port="4713"/>
  <outbound-socket-binding name="mail-smtp">
    <remote-destination host="${jboss.mail.server.host:localhost}" port="${jboss.mail.server.port:25}"/>
  </outbound-socket-binding>
</socket-binding-group>
```

sudo systemctl daemon-reload
sudo systemctl restart keycloak
sudo tail -f /opt/keycloak/standalone/log/server.log  # check logs

sudo systemctl enable keycloak
# se il servizio non va su, capire perché o se va lanciando lo script dritto
sudo /opt/keycloak/bin/standalone.sh


# https://www.keycloak.org/docs/latest/server_installation/#enabling-ssl-https-for-the-keycloak-server
sudo /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin
sudo /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE
# sudo /opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=EXTERNAL # per ripristinarlo


# serving from apache reverse proxy
sudo nano /etc/apache2/sites-available/keycloak.conf
```
# see versioned conf file
```
sudo a2ensite keycloak.conf
sudo systemctl restart apache2.service


# WILDFLY ACCOUNT SETUP
sudo /opt/keycloak/bin/add-user.sh
automation
<PASSWORD_INPUT_HERE>
[ ]     # leave groups blank
yes     # Is this correct?
yes     # Is this new user going to be used for one AS process to connect to another AS process?
# OUTPUTS To represent the user add the following to the server-identities definition <secret value="QmlvY2hhciMxMSEtd2lsZGZseQ==" />