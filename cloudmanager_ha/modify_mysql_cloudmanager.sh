#/bin/bash
cur_path=$(cd `dirname $0`; pwd)
. $cur_path/logger.sh

create_mysql_tables()
{
	if [[ $# != 1 ]];then
		logger error "the parameter of mysql tables is error,please check it out!"
		logger error "usage: $0 create {VIP}"
		exit 1
	fi

	vip=$1
	mysql -uroot -h127.0.0.1 -e "use cloud;update configuration set value= '$vip' where name = 'host';"
}
recover_mysql_tables()
{
	host_ip=`ifconfig cloudbr0 | grep "inet addr" | cut -f 2 -d ':' | cut -f 1 -d ' '`

	mysql -uroot -h127.0.0.1 -e "use cloud;update configuration set value = '$host_ip' where name ='host';"
}

case $1 in 
	create)
	create_mysql_tables $2
	;;
	recover)
	recover_mysql_tables
	;;
    *)
	logger error "usage: $0 {create | recover}"
	exit 1
	;;
esac
