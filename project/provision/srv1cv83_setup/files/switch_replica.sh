#!/bin/sh
db_server=slave.otus.lab
database_1c=1CDocDemo
db_user=barman
db_pwd=Pass@Word@Bar
infobase_user=Администратор

/opt/1C/v8.3/x86_64/ras --daemon cluster
sleep 10
CLUSTER_UUID=$(/opt/1C/v8.3/x86_64/rac cluster list | grep 'cluster' | awk '{ print $3 }')
BASE_UUID=$(/opt/1C/v8.3/x86_64/rac infobase --cluster=$CLUSTER_UUID summary list | grep infobase | awk '{print $3}')
PROC_UUID=$(/opt/1C/v8.3/x86_64/rac connection list --cluster=$CLUSTER_UUID | grep process | head -1 |awk '{print $3}')
CONN_UUID=$(/opt/1C/v8.3/x86_64/rac connection list --cluster=$CLUSTER_UUID | grep connection | head -1 |awk '{print $3}')

echo $CLUSTER_UUID
echo $BASE_UUID
echo $CONN_UUID

#opt/1C/v8.3/x86_64/rac infobase --cluster=$CLUSTER_UUID drop --infobase=$BASE_UUID --infobase-user='Администратор' 
# --infobase-user='Администратор' --dbms=PostgreSQL --db-server=$db_server --db-name=$database_1c --db-user=$db_use --db-pwd=$db_pwd --license-distribution=allow

#/opt/1C/v8.3/x86_64/rac cluster list 
#/opt/1C/v8.3/x86_64/rac infobase --cluster=$CLUSTER_UUID summary list

/opt/1C/v8.3/x86_64/rac connection --cluster=$CLUSTER_UUID disconnect  --process=$PROC_UUID --connection=$CONN_UUID

/opt/1C/v8.3/x86_64/rac infobase --cluster=$CLUSTER_UUID update --infobase=$BASE_UUID --infobase-user=$infobase_user --dbms=PostgreSQL --db-server=$db_server --db-name=$database_1c --db-user=$db_user --db-pwd=$db_pwd --license-distribution=allow

/opt/1C/v8.3/x86_64/rac infobase info --cluster=$CLUSTER_UUID --infobase=$BASE_UUID --infobase-user='Администратор'

