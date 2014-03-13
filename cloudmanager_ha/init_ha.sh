#!/bin/bash
cur_path=$(dirname $(readlink -f $0))
. $cur_path/logger.sh

start_master()
{
   #Modify the permissions
   chmod +x /etc/rc.d/init.d/functions
   chmod +x /etc/rc.d/init.d/realserver.sh 
   lsmod |grep ip_vs >/dev/null 2>&1
   if [[ $? -eq 0 ]];then
	   logger info "the module of ip_vs has been loaded!"
   else
	   logger info "the module has not been loaded,so load it first!"
	   exit 1
   fi

   /etc/rc.d/init.d/realserver.sh start >/dev/null 2>&1
   logger debug "realserver.sh is running."
   /etc/rc.d/init.d/keepalived start >/dev/null 2>&1
   logger debug "keepalived is running. "
}

stop_master()
{
  /etc/rc.d/init.d/realserver.sh stop >/dev/null 2>&1
  logger debug "realserver is stopped."
  /etc/rc.d/init.d/keepalived stop >/dev/null 2>&1
  logger debug "keeplived is stopped."
  
}

restart_master()
{
  stop_master
  start_master
}

status_master()
{
  
  lvs_file="/sbin/ipvsadm"
  if [[ ! -f "$lvs_file" ]];then 
	  logger error "LVS is not install,so start LVS failed!"
	  exit 1
  else
	  ipvsadm >/dev/null 2>&1
  fi
  keepalived_file="/var/run/keepalived.pid"

  if [[ ! -f "$keepalived_file" ]];then
	  logger error "keepalived is not started,please start first!"
	  exit 1
  else
	  /etc/rc.d/init.d/keepalived status >/dev/null 2>&1
      logger debug "the status of keepalived is normal."
  fi
}

case "$1" in
 start)
  start_master
 ;;
 stop)
  stop_master
 ;;
 restart)
  restart_master
 ;;
 status)
  status_master
 ;;
 *)
  echo "usage: $0 {start|stop|restart|status}"
 ;;
esac



