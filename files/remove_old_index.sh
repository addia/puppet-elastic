#!/usr/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
export PATH

#
##
###   Housekeeping   -   delete old indicies
###                      this script runs on the current master node
###
###        Running   -   run this via CRON between 22:00 and 23:00 every day
###
###
###
###   variables:
###   ----------
###     user changable vars: 
###       DAYS            -  set to a number of days to keep
###       INDEX_PREFIX    -  array of indicies space separated
###
###     change at own risk vars:
###       REMOVE_UNTIL    -  the calculated remove until date
###       SERVER_IP       -  this servers IP
###       MASTER_NODE     -  the hash of the current ELS master
###       THIS_NODE       -  the hash of the this ELS node
###
###
###
###   Author:  Addi <addi.abel@gmail.com>   Copyright  ©  2017
##
#


# we want to be root
# ------------------
if [ $UID -eq 0 ]
then
   /bin/true
else
   # Joe Blogs cannot run this
   exit 0
fi


# user variables
# --------------
DAYS=30
INDEX_PREFIX="logstash"


# system variables
# ----------------
SERVER_IP=`hostname -i`
REMOVE_UNTIL=$(date '+%Y%m%d' -d "${DAYS} days ago")
MASTER_NODE=`curl -s -XGET "http://${SERVER_IP}:9200/_cluster/state/master_node?human&pretty" | grep master_node | awk '{print $3}'`
THIS_NODE=`curl -s -XGET  "http://${SERVER_IP}:9200/_nodes/_local?human&pretty" | grep -A1 nodes | tail -1 | awk '{print $1}'`


# run on master node only
# -----------------------
if [ "$THIS_NODE" = "$MASTER_NODE" ]
then

    # now delete old indicies
    # -----------------------
    for INDEX_PREF in ${INDEX_PREFIX}
    do
        LIST=`curl -s -XGET  "http://${SERVER_IP}:9200/_cat/indices?v" | sort | grep ${INDEX_PREF} | awk '{print $3}'`
        for I in $LIST
        do
            DAT=$(echo ${I##${INDEX_PREF}-} |tr -d '.')
            if [ $DAT -lt $REMOVE_UNTIL ]
            then
                printf "$I  "
                curl -XDELETE "http://${SERVER_IP}:9200/${I}"
                printf "\n"
            fi
        done
    done

fi
