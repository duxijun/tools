#!/bin/bash
cur_path=$(cd `dirname $0`; pwd)
$cur_path/logger.sh

#if [ $# != 1 ];then
#	echo "parameter error."
#fi

user=cloud
pw=cloud
PORT=3306

touch $cur_path/mysql_info.out

create_account()
{
	peerIP=$1
	sql="grant replication slave on *.* to '$user'@'$peerIP' identified by '$pw'; grant all privileges on *.* to '$user'@'$peerIP' identified by '$pw';"
	#logger info "$sql "
	mysql -uroot -h127.0.0.1 -P$PORT -e "${sql};  flush privileges;" >/dev/null 2>&1

}

mod_mysql_conf()
{
  logger info  "run mod my.cnf"
  status=$1 
  $cur_path/create_mysql_conf.sh create $status 
  if [ $? -ne 0 ] ; then
	  logger error  "mod my.cnf failed!"
	  $cur_path/create_cloudmanager_conf.sh recover 
	  exit 1
  fi
  service mysqld restart >/dev/null 2>&1
}

create_mysql_info()
{
	out=$1
	mysql -uroot -h127.0.0.1 -P$PORT -e "flush tables  with read lock;" >/dev/null 2>&1
	File=`mysql -uroot -h127.0.0.1 -P3306 -Ae"show master status \G" | grep File |awk '{print $2}'`
	Pos=`mysql -uroot -h127.0.0.1 -P3306 -Ae"show master status \G" | grep Position |awk '{print $2}'`
	echo "$File" > $out
	echo "$Pos" >> $out
}

set_mysql_sync()
{
 if [ $# != 3 ];then
	 logger error "Please input right parameter!"
	 echo "usage: $0 sync [backup ip] [log_file] [log_pos]"
	 exit 1
 fi
	master_host=$1
	master_log_file=$2
	master_log_pos=$3
	sql="change master to master_host='${master_host}',master_port=3306, master_user='cloud',master_password='cloud',master_log_file='${master_log_file}',
	master_log_pos=${master_log_pos};"
    mysql -uroot -h127.0.0.1 -P$PORT -e "stop slave ;${sql}; unlock tables;" >/dev/null 2>&1
}

start_mysql_sync()
{
	mysql -uroot -h127.0.0.1 -P$PORT -e "start slave;" >/dev/null 2>&1
}

stop_mysql_sync()
{
    mysql -uroot -h127.0.0.1 -P$PORT -e "stop slave;" >/dev/null 2>&1
}

check_mysql_sync()
{
	io_status=`mysql -uroot -h127.0.0.1 -P3306 -Ae"show slave status \G" | grep Slave_IO_Running |awk '{print $2}'`
	mysql_status=`mysql -uroot -h127.0.0.1 -P3306 -Ae"show slave status \G" | grep Slave_SQL_Running |awk '{print $2}'`

	if  [[ "$io_status" = "Yes"  ]] && [[ "$mysql_status" = "Yes" ]]
	then
		logger info "Mysql replication is successful!"
        return 0
	else
		logger error "Mysql replication is error!"
		return 1
	fi
}

create_mysql_sync_account()
{
 if [ $# != 2 ];then
	 logger error "Please input the backup ip!"
	 echo "usage: $0 peerIP {MASTER | BACKUP}"
	 exit 1
 fi
	create_account $1
	mod_mysql_conf $2
	create_mysql_info ./mysql_info.out

}

case "$1" in
	create)
		create_mysql_sync_account $2 $3
	;;
	sync)
		set_mysql_sync $2 $3 $4
	;;
	status)
		check_mysql_sync
	;;
	start)
		start_mysql_sync
	;;
	stop)
		stop_mysql_sync
	;;
	*)
	 logger error "usage: $0 {create|sync|start|stop|status}"
	 exit 1
	;;
esac

