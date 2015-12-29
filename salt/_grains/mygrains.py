#!/bin/env python
# -*- coding: utf-8 -*-

import commands
import json

def getRoles():
	grains={}
	#must be IP
	status, output = commands.getstatusoutput("curl http://10.70.58.196/saltApi.php?ip=`cat /etc/salt-cntv/minion |grep 'id:' |sed 's/id: //g'` 2> /dev/null")
	result = json.loads(output)
	
	list = []
	for k in result["roles"]:
		list.append(k)
	grains['roles'] = list

	list = []
	for k in result["location"]:
		list.append(k)
	grains['location'] = list

	return grains
