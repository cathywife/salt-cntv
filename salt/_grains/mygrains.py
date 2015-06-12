#!/bin/env python

import commands
import json

def getRoles():
	grains={}
	status, output = commands.getstatusoutput("curl http://saltMaster/saltApi.php?ip=`cat /etc/salt/minion_id` 2> /dev/null")
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
