#!/bin/bash

cd /home/ubuntu/mysql-backups

BACKUP_FOLDER_LITE=$(date +%y%m%d)_lite

date
echo "Backing up plexus_cloud main tables"

mkdir $BACKUP_FOLDER_LITE
cd $BACKUP_FOLDER_LITE

mysqldump -h cloud-test-mysql.cehuqqmfsvm0.us-west-2.rds.amazonaws.com -P 3306 -u admin -p'Biochar#11!-mysql' --set-gtid-purged=OFF plexus_cloud alarms blackboxes devices notification_blacklist projects project_invitations users > "plexus_cloud_lite.sql";
zip "plexus_cloud_lite.sql.zip" "plexus_cloud_lite.sql"
rm "plexus_cloud_lite.sql"

cd ..

echo "Cleaning up 8-days-ago-old plexus_cloud lite backup"
FOLDER_TO_REMOVE=$(date +%y%m%d -d "8 days ago")_lite
rm -rf $FOLDER_TO_REMOVE ||:        # ||: this is to avoid crash if folder/files is missing

echo 'Backup complete!'
