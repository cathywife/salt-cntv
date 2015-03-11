import sys
import pam
import readline
from getpass import getuser, getpass
from random import choice

def input_with_prefill(prompt, text):
	def hook():
		readline.insert_text(text)
		readline.redisplay()
	readline.set_pre_input_hook(hook)

	if sys.version_info >= (3,):
		result = input(prompt)
	else:
		result = raw_input(prompt)

	readline.set_pre_input_hook()
	return result

p = pam.pam()
user = input_with_prefill('Username: ', getuser())
if p.authenticate(user, getpass()):
	print "PASS!"
else:
	print "FAILED %s,%s" % (p.code, p.reason)