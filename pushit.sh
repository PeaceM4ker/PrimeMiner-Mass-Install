#!/usr/bin/python
import paramiko
import os
import thread
import time
import sys, string, threading

outlock = threading.Lock()


with open("iplist.txt", 'r') as f:
    lines = f.readlines()

iplist=list(lines)

def ssh_work ( host ):
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(
	    paramiko.AutoAddPolicy())
	print "connecting to "+host
	ssh.connect(host, username='root', password='[yourpassword]')
	print "opening sftp connection for "+host
	sftp=ssh.open_sftp()
	sftp.put("/root/postinstall", "/root/postinstall")
	print "post install script copied to "+host
	sftp.close
	ssh.exec_command('chmod a+x ~/postinstall')
	print "executing postinstall script on "+host
        stdin, stdout, stderr = ssh.exec_command('(cd /root; ./postinstall)')
        print "stderr: ", stderr.readlines()
        print "pwd: ", stdout.readlines()

	with outlock:
		print stdout.readlines()

def ssh_thread():
	hosts = lines
	threads = []
	for h in hosts:
		t = threading.Thread(target=ssh_work, args=(h,))
		t.start()
		threads.append(t)
	for t in threads:
		t.join()
ssh_thread()
