#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

echo $TYPE $HAME $STATUS 

#请指定虚拟IP与网关地址
VIP=VIP_IP
GATEWAY=`netstat -r|grep default|cut -f 10 -d ' '`
LOGGERFILE="/var/log/cloud/cloudmanager_ha.log"

#请指定该节点默认为MASTER/BACKUP
DEFAULTSTATE="MASTER"

function sendArp
{
   arping -I cloudbr0 -c 2 -s $VIP $GATEWAY &>/dev/null
}

function chkPara
{
   if [ -z "$VIP" -o -z "$GATEWAY" ]; then 
      echo  "[ERROR] Virtual IP address or gateway is not properly configured. Check the configuration." >>$LOGGERFILE
      exit 1
   fi
   if [ "$DEFAULTSTATE" != "MASTER" -a "$DEFAULTSTATE" != "BACKUP" ]; then
      echo  "[ERROR] Default state is not properly configured. Check the configuration." >>$LOGGERFILE
      exit 1
   fi
}

function master
{
	#当状态切换为master时调用
	echo  "State translate to MASTER..." >>$LOGGERFILE
	sleep 3
	sendArp
	#if [ "$DEFAULTSTATE" == "BACKUP" ]; then
     #     logger "$(service cloudmanager stop)"
	  #logger "$(service mysqld restart)"
	  #logger "$(service cloudmanager start)"
	#fi
}

function backup
{
	#当状态切换为backup时调用
	echo "State translate to BACKUP" >>$LOGGERFILE
	#sleep 4
	#if [ "$DEFAULTSTATE" == "BACKUP" ]; then
	  #logger "$(service cloudmanager stop)"
	  #logger "$(service mysqld restart)"
	  #logger "$(service cloudmanager start)"
	#fi
}

function fault
{
	#当状态切换为fault时调用
	echo "State translate to FAULT" >>$LOGGERFILE
}

#logger "=========="
#logger "Notify on $(date)"
chkPara

case $STATE in
    "MASTER") 
		master
        exit 0
	;;
    "BACKUP") 
		backup
        exit 0
    ;;
    "FAULT")  
		fault
        exit 0
    ;;
    *)        
		echo "[ERROR]Unknown state detected." >>$LOGGERFILE
        exit 1
		;;
esac

