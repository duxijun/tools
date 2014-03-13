#!/usr/bin/env python

#server.py
import socket
from com_logger import *

BUFFER=4096
PORT=7788
op_list= ["ADD","DEL","STATUS"]
FILE='CloudManager_HA.out'

def get_backup_ip(cmd):
	strlist = cmd.split('@')
	if len(strlist) < 2:
		logger.error('cmd is error.')
		sys.exit()
	return strlist[1]
	
def get_local_host_ip():
	myname = socket.getfqdn(socket.gethostname())
	myaddr = socket.gethostbyname(myname)
	logger.info('myname= %s,myaddr= %s' %(myname,myaddr))
	return myaddr

def write_file(data):
	file_object = open(FILE, 'w')
	file_object.write(data)
	file_object.close()

def send_data_to_server(host,cmd):
	if len(host) == 0:
		logger.error('host is error.')
		sys.exit()
	logger.info('host=%s,cmd=%s,port=%d' %(host,cmd,PORT))
	sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((host,PORT))
	sock.send(cmd)
	ret = sock.recv(BUFFER)
	print ret
	write_file(ret)
	sock.close()

def main():
	if(len(sys.argv) != 2) :
		logger.error('Usage : python %s cmd@masterip@backupip@..' %(sys.argv[0]))
		sys.exit()
	cmd = sys.argv[1]
	req = cmd.split('@')

	if len(req) < 3:
		logger.error ('Usage : python %s cmd@masterip@backupip@..' %(sys.argv[0]))
		sys.exit()

	serIP = req[1]
	op_type = req[0]
	check_op = False
	op_type = op_type.upper()
	
	for type in op_list:
		if type == op_type:
			check_op = True
			break
	
	if check_op == False:
		logger.error ('cmd is error, usage:{add|del|status}' )
		sys.exit()
	
	if op_type == "ADD":
		if len(req) != 4:
			logger.error ('Usage : python %s add@masterip@backupip@vip' %(sys.argv[0]))
			sys.exit()
	else:
		if len(req) != 3:
			logger.error ('Usage : python %s {del|status}@masterip@backupip' %(sys.argv[0]))
			sys.exit()

	send_data_to_server(serIP,cmd)

if __name__ == '__main__':
	main()


