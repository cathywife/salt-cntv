createrepo:
  pkg.latest

/data/www/cntvInternal.repo:
  file.managed:
    - source: salt://common/yumRepo/cntvInternal.repo
    - user: nginx
    - group: nginx
    - mode: 0755
    - makedirs: True

/usr/local/cntv/yumSync/rsync.sh:
  file.managed:
    - source: salt://project/yumRepo/files/rsync.sh
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

/usr/local/cntv/yumSync/exclude.list:
  file.managed:
    - source: salt://project/yumRepo/files/exclude.list
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True

/repo/cntvInternal:
  file.recurse:
    - source: salt://project/yumRepo/repos/cntvInternal
    - exclude_pat: E@\.svn
    - user: root
    - group: root
    - file_mode: 0755
    - dir_mode: 0755
    - makedirs: True
    - clean: True

/repo/cntvCdh5:
  file.recurse:
    - source: salt://project/yumRepo/repos/cntvCdh5
    - exclude_pat: E@\.svn
    - user: root
    - group: root
    - file_mode: 0755
    - dir_mode: 0755
    - makedirs: True
    - clean: True

/usr/local/cntv/yumSync/cntvInternalRepoSync.sh:
  file.managed:
    - source: salt://project/yumRepo/files/cntvInternalRepoSync.sh
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True
    - require:
      - pkg: createrepo

yumRepo_run:
  cmd.run:
    - name: '/usr/local/cntv/yumSync/cntvInternalRepoSync.sh'
    - user: root
    - require:
      - file: /repo/cntvInternal
      - file: /usr/local/cntv/yumSync/cntvInternalRepoSync.sh

/usr/local/monit/etc/inc/yumRepo.cfg:
  file.managed:
    - source: salt://project/yumRepo/files/yumRepo-monit.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

yumRepo_monit:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    - watch:
      - file: /usr/local/monit/etc/inc/yumRepo.cfg

##计划任务@@
{% if "crontab" in grains["roles"] %}
yumRepo-crontab:
  file.blockreplace:
    - name: /etc/crontab
    - marker_start: "## yumRepo start ##"
    - marker_end: "## yumRepo end ##"
    - content: |
        23 1-4 * * * root /usr/local/cntv/yumSync/rsync.sh
        */10 * * * * root /usr/local/cntv/yumSync/cntvInternalRepoSync.sh
    - append_if_not_found: True
    - backup: '.bak'
{% endif %}