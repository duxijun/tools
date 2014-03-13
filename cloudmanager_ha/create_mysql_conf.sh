#!/bin/bash
#
# the purpose of this script:
# create the configuration of mysql
# recover mysql
#
cur_path=$(cd `dirname $0`; pwd)
. $cur_path/logger.sh

create_mysql_conf()
{
	#Test function parameters
	if [ $# != 1 ];then
		logger error "the parameter of mysql is error."
		logger error "usage: $0 create {MASTER|BACKUP}"
		exit 1
	fi

	#Initialize the parameter
	mysql_path=$cur_path/conf
	mysql_conf=my.cnf
	mysql_conf_bak=my.cnf.bak

	status=$1

	#check whether mysql is installed
	mysql_package=`rpm -qa|grep mysql-server|wc -l`

	if [[ $mysql_package -eq 0 ]];then
		logger info "mysql does not installed!"
		yum install -y mysql-server
	fi

	#Modify /etc/my.cnf
	\cp $mysql_path/$mysql_conf $mysql_path/$mysql_conf_bak
	if [[ $status == "MASTER" ]];then
		sed -i "s/num/1/g" $mysql_path/$mysql_conf_bak
		sed -i "s/offset_value/1/g" $mysql_path/$mysql_conf_bak
		\mv $mysql_path/$mysql_conf_bak /etc/$mysql_conf
	elif [[ $status == "BACKUP" ]];then
		sed -i "s/num/2/g" $mysql_path/$mysql_conf_bak
		sed -i "s/offset_value/2/g" $mysql_path/$mysql_conf_bak
		\mv $mysql_path/$mysql_conf_bak /etc/$mysql_conf
	fi
}


recover_mysql_conf()
{
	mysql_path=/etc/my.cnf
	sed -i '/server-id/d' $mysql_path
    sed -i '/log-bin/d' $mysql_path
	sed -i '/binlog-do-db/d' $mysql_path
	sed -i '/binlog-ignore-db/d' $mysql_path
	sed -i '/replicate-do-db/d' $mysql_path
	sed -i '/replicate-ignore-db/d' $mysql_path
	sed -i '/sync_binlog/d' $mysql_path
	sed -i '/log-slave-updates/d' $mysql_path
	sed -i '/slave-skip-errors/d' $mysql_path
	sed -i '/auto_increment_increment/d' $mysql_path
	sed -i '/auto_increment_offset/d' $mysql_path
	sed -i '/binlog_format/d' $mysql_path
}

case $1 in
	create)
    create_mysql_conf $2
	;;
    recover)
	recover_mysql_conf 
	;;
	*)
	logger error "usage: $0 {create | recover}"
	exit 1
	;;
esac
