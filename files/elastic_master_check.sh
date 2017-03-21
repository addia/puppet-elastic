#!/usr/bin/bash
#
##   check the master and node ID
##
##   original from Mr. Chris Hatten - modified by Addi.
#

SERVER_IP=`hostname -i`
NODE=$(curl -s -XGET "http://${SERVER_IP}:9200/_nodes/_local?human&pretty" | grep -A1 '\"nodes\"' | tail -1 | awk '{print $1}')
MASTER=$(curl -s -XGET "http://${SERVER_IP}:9200/_cluster/state/master_node?human&pretty" | grep master_node | awk '{print $3}')
SERVICE_NAME=$(systemctl  | grep -v mount | grep elastic | awk '{print $1}')
SYSTEMCTL_STATUS=systemctl status ${SERVICE_NAME} | grep --color=always active

echo
echo "Service status: " $SYSTEMCTL_STATUS


if  [ -z ${NODE} ]
then
 echo Node is not running
fi

if [ -z ${MASTER} ]
then
 echo Cluster is not running
fi

echo
echo "This Hostname:  " hostname
echo
echo "IP address:     " ${SERVER_IP}
echo
echo "Cluster node ID:" ${NODE}
echo
echo "Master node ID: " ${MASTER}
echo

if  [ -n ${MASTER} ] || [ -n ${NODE} ]
then
  if [ "${NODE}" == "${MASTER}" ]
  then
     echo "This is the current MASTER the node."
  else
     echo "This is NOT the master node."
  fi
fi

echo
