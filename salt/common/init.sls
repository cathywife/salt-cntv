include:
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
  - common.salt-minion
  - common.sudoers
  - common.user
  - common.yumRepo
  {% set desc = pillar["desc"][0] %}
  {% if (not desc.startswith("flvSource")) and (not desc.startswith("api.cntv.cn")) %}
  - common.cntvCms
  - common.openLdap
  #- common.zabbixAgent
  {% endif %}

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

common_pkgs:
  pkg.installed:
    - names:
{% if grains['os_family'] == "RedHat" %}
      - rsync
      - wget
      - gcc
      - make
{% endif %}
    - require:
      - file: /etc/yum.repos.d/cntvInternal.repo

#用户安全
unlockPasswd:
  cmd.run:
    - name: chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
    - user: root
    - order: 1

lockPasswd:
  cmd.run:
    - name: chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow
    - user: root
    - order: last