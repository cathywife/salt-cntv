#!/usr/bin/env python
# coding: utf-8

from fabric.api import *
from fabric.colors import *
from fabric.contrib.console import confirm

#主机列表
env.hosts = ['10.70.36.196','10.70.36.197']

#用户名密码
env.user = 'xtyw'
env.password = 'Xtyw1111'

#命令执行超时(s)
env.command_timeout = 20
#连接超时(s)
env.timeout = 3
#连接重试
env.connection_attempts = 3
#sudo提示信息
#env.sudo_prompt = "sudo password:"

#run/sudo/local仅提示错误不退出
env.warn_only = True
#遇到交互抛出SystemExit异常并退出(使用except SystemExit防止退出)
env.abort_on_prompts = True
#跳过连接不上的主机
env.skip_bad_hosts = True
#彩色错误输出
env.colorize_errors = True
#避免添加到本机的known_hosts
env.disable_known_hosts = True
#使用PTY
env.always_use_pty = True
#sudo用户
env.sudo_user = "root"

def go():
	#confirm(question, default=True)
	with settings(
		#hide('aborts', 'warnings', 'running', 'stdout', 'stderr'),
		warn_only=True
	):
		try:
			put('installSalt.sh', '/tmp/go.sh')
			sudo("/bin/bash /tmp/go.sh")
			sudo("rm -f /tmp/go.sh")
		except SystemExit:
			print (red("[E]	interactive found."))