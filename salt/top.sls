#该文件作用：链接roles和软件包的安装关系，链接roles和特殊项目的关系，用该文件指定roles需要的软件。
#软件的配置可以使用pillar匹配roles，从而做到定制化配置。

#top.sls	指定roles安装什么软件
#pillar		指定软件应用什么配置
#project目录	roles对应的特定包（软件+配置）

base:
  'roles:base':
    - match: pillar
    - common

  'I@roles:svnServer-weibo':
    - match: compound
    - svnServer

  'I@roles:api.cntv.cn-web':
    - match: compound
    - project.api-ctnv-cn-monit
    - beaver

  'I@roles:yumRepo':
    - match: compound
    - project.yumRepo
    - nginx

  'I@roles:tms-rsync or I@roles:tms-ftp or I@roles:tms-app or I@roles:tms-mysql or I@roles:api.cntv.cn-web':
    - match: compound
    - common.cmdHistoryAudit
    - common.rsyslog
    - common.crontab
    - common.user
    - common.motd
    - common.cntvSysCmds
    - common.monit
    - common.sudoers

  'I@roles:cdnSource-img or I@roles:cdnSource-page':
    - match: compound
    - common.cmdHistoryAudit
    - common.rsyslog
    - common.crontab
    - common.user
    - common.motd
    - common.cntvSysCmds
    - common.monit
    - common.sudoers
    - beaver

  'I@roles:logstash-indexerSyslog or I@roles:logstash-indexerBeaver':
    - match: compound
    - logstash

  'I@roles:logstash-es*':
    - match: compound
    - elasticsearch

  'I@roles:redis':
    - match: compound
    - redis

  'I@roles:syslogCenter':
    - match: compound
    - beaver

  'I@roles:saltMaster':
    - match: compound
    - beaver











#  'roles:admin-svnServer':
#    - match: pillar
#    - project.cntvSvnServer

#  'I@roles:logstash-es*':
#    - match: compound
#    - elasticsearch

#  'I@roles:logstash-*indexer':
#    - match: compound
#    - logstash

#  'I@roles:logstash-redis':
#    - match: compound
#    - redis

#  'I@roles:beaver':
#    - match: compound
#    - beaver

#  'I@roles:admin-svnServer or I@roles:admin-svnServer-cluster63.228':
#    - match: compound