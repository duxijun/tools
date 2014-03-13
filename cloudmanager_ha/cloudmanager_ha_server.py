#!/usr/bin/env python

import socket, threading
from com_logger import *
from sync_mysql import  create_account,set_sync,start_sync,stop_sync,check_sync,read_sync 
import signal
from init_ha import *


OP_TYPE_CMD=0
OP_TYPE_LOCAL_CMD=1
OP_TYPE_DATA=2
OP_TYPE_FILE=3


listen_port = 7788 
conn_list = []  
conn_timeout = 120 
max_connections = 50
file = ''
pos = ''
snpath='/var/sn/'

def cloudmanager_ha_client(host,cmd):
	sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((host,listen_port))
	sock.send(cmd)
	ret=sock.recv(4096)
	sock.close()
	return ret



def handler_error(masterip ,backupip):
	ret = 0 
	cmd = 'DEL' + '@' +masterip +'@' +backupip
	ret = cloudmanager_ha_client(backupip,cmd)
	if ret != 0:
		logger.error('Del backup node HA failed!')

	ret = cloudmanager_ha_client(masterip,cmd)
	if ret != 0:
		logger.error('Del master node HA failed!')
		
	return ret 
		
def cloudmanager_ha_status(masterip,backupip,type):
	"""@todo: Docstring for cloudmanager_ha_status.

	:arg1: @todo
	:returns: @todo

	"""
	ret = '0'
	ret_master = '1'
	ret_slave = '1'
	master_flag = 0
	slave_flag = 0
	logger.info ('Starting check ha status ...')
	for cmd in type.split('@'):
		cmd = cmd + '@' + masterip +'@'+backupip
		logger.info ('ha_status command is %s' %(cmd))
		ret_slave=cloudmanager_ha_client(backupip,cmd)
		if ret_slave != '0':
			logger.error('Slave:%s send command:%s failed!' %(backupip,cmd))
			ret_slave = '1'
			slave_flag = 1
		ret_master = cloudmanager_ha_client(masterip,cmd)
		if ret_master != '0':
			logger.error('Master:%s send command:%s failed!' %(masterip,cmd))
			ret_master= '1'
			master_flag = 1
			
	if slave_flag == 1:
		ret_slave = '1'
	if master_flag == 1:
		ret_master = '1'
		
	ret = str(ret_master) + '#' + str(ret_slave)
	return ret

def get_op_status(action):
	if action in ('ADD','DEL','STATUS','MYSQL'):
		op_status = OP_TYPE_CMD
	elif action in	('DATA'):
		op_status = OP_TYPE_DATA
	elif action in ('FILE#GET','FILE#PUT'):
		op_status = OP_TYPE_FILE
	else:
		op_status= OP_TYPE_LOCAL_CMD
	return op_status

class Watcher: 
	def __init__(self):
		self.child = os.fork()
		if self.child == 0:
			return
		else:
			self.watch()

	def watch(self):
		try:
			os.wait()
		except KeyboardInterrupt:
			logger.error('KeyboardInterrupt')
			self.kill()
		sys.exit()

	def kill(self):
		try :
			os.kill(self.child, signal.SIGKILL)
			os.kill(self.child, signal.SIGINT)
			os.kill(self.child,signal.SIGTERM)
			ret=os.system('lsof -i:%d >/dev/null 2>&1' %(listen_port))
			ret = ret >> 8
			if ret != 0:
				pass
			else:	
				os.system('service mysqld restart >/dev/null 2>&1')
				os.system('service keepalived restart >/dev/null 2>&1')
				os.system('service cloudmanager restart >/dev/null 2>&1')
		except OSError:
			pass

	
class CloudManagerHAConnection(threading.Thread):  
	def __init__(self, fd):  
		threading.Thread.__init__(self)  
		self.fd = fd  
		self.running = True 
		self.master = False
		self.setDaemon(False)  
		self.alive_time = time.time()
		self.vip=''

		
	def send_message(self,masterip,backupip,type):
		ret = '0'
		if self.master == False:
			logger.debug('backup return')
			return ret 

		logger.info ('Starting send message ...')
		for cmd in type.split('@'):
			if cmd == "HA_CREATE":
				cmd = cmd + '@' + masterip +'@'+backupip + '@' + self.vip
			else :
				cmd = cmd + '@' + masterip +'@'+backupip
		
			logger.debug ('command is %s' %(cmd))
			ret=cloudmanager_ha_client(backupip,cmd)
			if ret != '0':
				logger.error('Slave:%s send command:%s  failed!' %(backupip,cmd))
				ret = '1'
				break
			ret = cloudmanager_ha_client(masterip,cmd)
			if ret != '0':
				logger.error('Master:%s send command:%s failed!' %(masterip,cmd))
				ret= '1'
				break

		if ret == '1':
			logger.warning('roll back')
			handler_error(masterip,backupip)
			
		return ret

	def send_file_message(self,host,cmd):
		sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.connect((host,listen_port))
		logger.debug('cmd =%s ' %(cmd))
		cmd.strip()
		#while True:
		logger.info ('starting send file!')
		sock.send(cmd)
		time.sleep(0.5)
		if cmd.split('@')[0] == "GET":
			if os.path.exists(snpath):
				pass
			else:
				os.makedirs(snpath)
			with open(cmd.split('@')[1],'wb') as f:
				while 1:
					data = sock.recv(4096)
					if data == 'EOF':
						break
					f.write(data)
			logger.info ('Send file successful!')
		elif cmd.split('@')[0] == "PUT":
			with open(cmd.split('@')[1],'rb') as f:
				data = f.read()
			sock.sendall(data)
			time.sleep(0.5)
			sock.sendall('EOF')
		else:
			logger.error('Send file failed!')
		#break
		sock.close()		
		ret = 0
		return ret 

		
	def handler_op_cmd(self,masterip,backupip,op_type):
		if op_type == "MYSQL":
			cmd = 'MY_CREATE'+'@' + 'MY_INFO'+'@'+'MY_SYNC'+'@'+'MY_START'
		elif op_type == "ADD":
			cmd = "HA_CREATE"+'@' + "MYSQL" + '@' +"HA_START"
		elif op_type == "DEL":	
			cmd = "HA_STOP" + '@' + "MY_STOP" + '@'+"HA_DEL_CONF"
		elif op_type == "STATUS":
			cmd = "HA_STATUS" + "@" + "MY_CHECK"
			ret = cloudmanager_ha_status(masterip,backupip,cmd)
			return ret
		else:
			logger.error('Command is error!')
		ret = self.send_message(masterip,backupip,cmd)	
		return ret
	
	def hanlder_op_local_cmd(self,masterip,backupip,peerip,op_type):
		global file
		global pos
		if op_type == "MY_CREATE":
			ret = create_account(peerip,self.master)
		elif op_type == "MY_INFO":
			(ret,log_file,log_pos) = read_sync()
			cmd = 'DATA' + '@' + masterip +'@' + backupip + '@' + log_file + '#' + log_pos
			if self.master == True:	
				host = backupip
			else:
				host = masterip
			logger.debug ('Commdand:%s is sent to %s' %(cmd,host))
			ret = cloudmanager_ha_client(host,cmd)
		elif op_type == "MY_SYNC":
			logger.debug('mysql info:peerip=%s log_file=%s,log_pos=%s' %(peerip,file,pos))
			ret = set_sync(peerip, file, pos)
		elif op_type == "MY_START":
			ret = start_sync()
		elif op_type == "MY_STOP":
			ret = stop_sync()
		elif op_type == "MY_CHECK":
			ret = check_sync()
		elif op_type == "HA_CREATE":
			logger.debug('create conf vip=%s' %(self.vip))
			ret = create_ha_conf(self.master,masterip,backupip,self.vip)
			if self.master == True:
				cmd = 'FILE#PUT'+'@' + masterip +'@' + backupip
				ret = cloudmanager_ha_client(masterip,cmd)	
		elif op_type == "HA_DEL_CONF":
			ret = release_ha_conf()
		elif op_type == "HA_START":
			ret = start_ha()
		elif op_type == "HA_STOP":
			ret = stop_ha()
		elif op_type == "HA_STATUS":
			ret = status_ha()
		return ret

	def handler_op_data(self,cmd):
		global file
		global pos
		logger.debug('Receive Data: cmd=%s' %(cmd))
		file = cmd.split('#')[0]		
		pos = cmd.split('#')[1]
		return '0'

	def handler_op_file(self,backupip,op_type,filename):
		if op_type == "FILE#GET":
			cmd = op_type.split('#')[1]+'@' + filename
		elif op_type == "FILE#PUT":
			cmd = op_type.split('#')[1]+ '@' + filename

		ret = self.send_file_message(backupip,cmd)
		return ret

	def process(self, cmd):
		logger.info ('Process receive %s' %(cmd))
		req= cmd.split('@')
		if len(req) < 3:
			logger.error ('Command is error!')
			ret = 1
			self.fd.send(str(ret))
			return ret
		myaddr = socket.gethostbyname(socket.gethostname())
		op_type = req[0]
		op_type = op_type.upper()
		masterip = req[1]
		backupip = req[2]
		if myaddr == masterip:
			self.master = True
			peerip = backupip
		else:	
			peerip = masterip
			self.master = False
	
		op_status = get_op_status(op_type)
		logger.info ('Command=%s,masterip=%s,backupip=%s,peerip=%s op_status =%d' %(op_type,masterip,backupip,peerip,op_status))
	
		if op_status == OP_TYPE_CMD:
			if len(req) == 4:
				self.vip = req[3]
			ret = self.handler_op_cmd(masterip,backupip,op_type)
		elif op_status == OP_TYPE_LOCAL_CMD:
			if len(req) == 4:
				self.vip = req[3]
			ret = self.hanlder_op_local_cmd(masterip,backupip,peerip,op_type)
		elif op_status == OP_TYPE_DATA:
			if len(req) != 4:
				logger.warning ('recieve nothing!')
			ret = self.handler_op_data(req[3])
		elif op_status == OP_TYPE_FILE:
			for filename in os.listdir(snpath):
				filename = snpath+filename
				ret = self.handler_op_file(backupip,op_type,filename)
		
		logger.debug ('Send command result ret=%s' ,ret)
		self.fd.send(str(ret))
                 
	def run(self):  
		''''' Connection Process '''  
		try:  
			if len(conn_list) > max_connections:  
				logger.error ('Too many connections!')
				self.fd.close()  
				self.running = False  
				return  
			# Command Loop  
			while self.running:
				data = self.fd.recv(4096).strip()
				if len(data) == 0:
					break
				time.sleep(0.5)
				client_input = data.split('@')
				if client_input[0] == 'GET':
					with open(client_input[1],'rb') as f:
						data = f.read()
					self.fd.sendall(data)
					time.sleep(0.5)
					self.fd.sendall('EOF')
					continue
				elif client_input[0] == 'PUT':
					if os.path.exists(snpath):
						pass
					else:
						os.makedirs(snpath)
					with open(client_input[1],'wb') as f:
						while 1:
							data = self.fd.recv(4096)
							if data == 'EOF':
								break
							f.write(data)
						logger.info('Send file successful!')
				else:		
					self.process(data)
		except:  
			print sys.exc_info()

		self.running = False  
		self.fd.close()  
		logger.info ('Connection end')
  
  
def server_listen():  
	global conn_list
	listen_ip=socket.gethostbyname(socket.gethostname())
	listen_fd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
	listen_fd.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  
	listen_fd.bind((listen_ip, listen_port))  
	listen_fd.listen(5)  
	conn_lock = threading.Lock()  
	logger.info ('CloudmanagerHA server is listening on %s:%s' %(listen_ip,listen_port))
  
	while True:  
		conn_fd, remote_addr = listen_fd.accept()  
		logger.info ('connection from %s conn_list=%d' %(remote_addr,len(conn_list))) 
		conn = CloudManagerHAConnection(conn_fd)
		conn.start()  
  
		conn_lock.acquire()  
		conn_list.append(conn)  
		# check timeout  
		try:  
			curr_time = time.time()  
			for conn in conn_list:  
				if int(curr_time - conn.alive_time) > conn_timeout:  
					if conn.running == True:  
						conn.fd.shutdown(socket.SHUT_RDWR)  
					conn.running = False  
			conn_list = [conn for conn in conn_list if conn.running]  

		except:  
			print sys.exc_info()  
		conn_lock.release()  

def main(): 
	Watcher()
	server_listen()  
      
if __name__ == "__main__":  
	main() 
