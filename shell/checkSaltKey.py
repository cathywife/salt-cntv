#!/usr/bin/env python
# coding: utf-8

import csv
import subprocess
import multiprocessing
import time
import os

def get_hostList():
	hosts = []
	file = open("../data/saltServersList.csv")
	#file.readline()
	reader = csv.reader(file)
	for row in reader:
		if not row[0].startswith("#"):
			hosts.append(row[0])
	return hosts

def get_saltAccept():
	hosts = []
	child = subprocess.Popen("salt-key -l accept |grep ^[0-9]", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		resultS, resultE = child.communicate(timeout=300)
		resultC = child.returncode
	except subprocess.TimeoutExpired:
		child.kill()
		resultS, resultE = proc.communicate()
		resultC = child.returncode
	hosts = resultS.split('\n')
	return hosts

def del_saltHost(host):
	child = subprocess.Popen("salt-key -y -d " + host, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		resultS, resultE = child.communicate(timeout=300)
		resultC = child.returncode
	except subprocess.TimeoutExpired:
		child.kill()
		resultS, resultE = proc.communicate()
		resultC = child.returncode
	print resultS

def accept_saltKey(host,i):
	child = subprocess.Popen("salt-key -y -a " + host, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	try:
		resultS, resultE = child.communicate(timeout=300)
		resultC = child.returncode
	except subprocess.TimeoutExpired:
		child.kill()
		resultS, resultE = proc.communicate()
		resultC = child.returncode
	print resultS

#多任务处理
def multiprocess(hosts, child=10):
	len_hosts = len(hosts)
	print	'[*] total %d target(s)\n' \
			'[*] running %d hosts parallel' % (len_hosts, child)
	i = 1
	for host in hosts:
		print '[*] performing %s on %s [%d/%d]' % ("accept_saltKey", host, i, len_hosts)
		hostfork = multiprocessing.Process(target=accept_saltKey,args=(host,i))
		hostfork.start()
		#超过子进程数量后等待
		while len(multiprocessing.active_children()) >= child:
			time.sleep(0.001)
		time.sleep(0.001)
		i += 1
	#等待进程执行完毕
	while multiprocessing.active_children():
		time.sleep(1)

def main():
	hostsCSV = get_hostList()

	multiprocess(hostsCSV)

	hostsSalt = get_saltAccept()
	
	count=0
	for hostC in hostsCSV:
		if hostC in hostsSalt:
			#print hostC + "\tPASS"
			count = count + 1
			hostsSalt.remove(hostC)
		else:
			print hostC + "\tFAIL"
	
	print str(count)+"hosts pass."
	hostsSalt.remove("")

	for hostDel in hostsSalt:
		del_saltHost(hostDel)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print '\nbye bye!!!'
        time.sleep(0.2)
        os._exit(1)
