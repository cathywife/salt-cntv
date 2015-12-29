##添加系统用户@@
autoOps:
  group:
    - present
  user.present:
    - uid: 7878
    - shell: "/bin/bash"
    - home: "/home/autoOps"
    - groups:
        - autoOps
        - wheel

/home/autoOps/.ssh/authorized_keys:
  file.managed:
    - user: autoOps
    - group: autoOps
    - file_mode: 600
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:autoOps:sshKey_pub
    - require:
      - user: autoOps

/var/spool/cron/autoOps:
  file.managed:
    - source: salt://common/crontab/autoOps
    - user: autoOps
    - group: root
    - mode: 0600
    - require:
      - user: autoOps

