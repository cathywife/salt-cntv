#该文件作用：链接roles和软件包的安装关系，链接roles和特殊项目的关系，用该文件指定roles需要的软件。
#软件的配置可以使用pillar匹配roles，从而做到定制化配置。

#top.sls	指定roles安装什么软件
#pillar		指定软件应用什么配置
#project目录	roles对应的特定包（软件+配置）

base:
  'P@roles:baseA':
    - match: compound
    - common

  'P@roles:baseB':
    - match: compound
    - common.baseHosts
    - common.basePkgs
    - common.cmdHistoryAudit
    - common.rsyslog
    - common.crontab
    - common.sshd-key
    - common.motd
    - common.cntvSysCmds
    - common.monit
    - common.sudoers
    - common.yumRepo

  'P@roles:baseLite':
    - match: compound
    - common.baseHosts
    - common.basePkgs
    - common.motd
    - common.cntvSysCmds

  'P@roles:logCollecter':
    - match: compound
    - beaver

  'P@roles:svnServer':
    - match: compound
    - svnServer

  'P@roles:yumRepo':
    - match: compound
    - project.yumRepo
    - nginx

  'P@roles:api.cntv.cn-web':
    - match: compound
    - project.api-cntv-cn-web

  'P@roles:logstash-indexer*':
    - match: compound
    - logstash

  'P@roles:logstash-es*':
    - match: compound
    - elasticsearch

  'P@roles:collectd':
    - match: compound
    - collectd

  'P@roles:redis':
    - match: compound
    - redis

  'P@roles:smtpRelayServer':
    - match: compound
    - postfix

  'P@roles:cdh5':
    - match: compound
    - cdh5

  'P@roles:docker':
    - match: compound
    - docker

  'P@roles:kafka-zk':
    - match: compound
    - zookeeper

  'P@roles:kafka':
    - match: compound
    - kafka

  'P@roles:es2':
    - match: compound
    - elasticsearch2

#  'P@roles:(tms-rsync|tms-ftp|tms-app|tms-mysql|api.cntv.cn-web|cdnSource-img|cdnSource-page|cdnSource-page|openLDAP)':
#    - match: compound