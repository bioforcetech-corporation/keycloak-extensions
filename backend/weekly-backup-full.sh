#!/bin/bash

cd /home/ubuntu/mysql-backups

BACKUP_FOLDER=$(date +%y%m%d)_full

date
echo "Backing up databases"

mkdir $BACKUP_FOLDER
cd $BACKUP_FOLDER

mysqldump -h cloud-test-mysql.cehuqqmfsvm0.us-west-2.rds.amazonaws.com -P 3306 -u admin -p'Biochar#11!-mysql' --set-gtid-purged=OFF --routines keycloak > "keycloak.sql";
zip "keycloak.sql.zip" "keycloak.sql"
rm "keycloak.sql"

mysqldump -h cloud-test-mysql.cehuqqmfsvm0.us-west-2.rds.amazonaws.com -P 3306 -u admin -p'Biochar#11!-mysql' --set-gtid-purged=OFF --routines plexus_cloud > "plexus_cloud_full.sql";
zip "plexus_cloud_full.sql.zip" "plexus_cloud_full.sql"
rm "plexus_cloud_full.sql"

cd ..

echo "Cleaning up previous weekly 7-days-ago-old full backup"
FOLDER_TO_REMOVE=$(date +%y%m%d -d "7 days ago")_full
rm -rf $FOLDER_TO_REMOVE ||:        # ||: this is to avoid crash if folder/files is missing

echo 'Backup complete!'
