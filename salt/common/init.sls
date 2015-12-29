include:
  - common.baseHosts
  - common.basePkgs
  - common.cmdHistoryAudit
  - common.cntvSysCmds
  - common.baseOptimize
  - common.crontab
  - common.hosts
  - common.monit
  - common.motd
  - common.rcLocal
  - common.resolv
  - common.rsync
  - common.rsyslog
  - common.sshd
  - common.sshd-key
  - common.salt-minion-cntv
  - common.sudoers
  - common.yumRepo
  #- common.openLdap
  #- common.cntvCms
  #- common.zabbixAgent

/usr/local/cntv/shell:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

/usr/local/cntv/pkg:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 644
    - makedirs: True

#用户安全
unlockPasswd:
  cmd.run:
    - name: chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
    - user: root
    - onlyif: 'lsattr /etc/passwd |grep "i"'
    - order: 1

#lockPasswd:
#  cmd.run:
#    - name: chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow
#    - user: root
#    - order: last