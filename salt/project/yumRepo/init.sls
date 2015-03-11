createrepo:
  pkg.installed

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

/usr/local/cntv/yumSync/cntvInternalRepoSync.sh:
  file.managed:
    - source: salt://project/yumRepo/files/cntvInternalRepoSync.sh
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True
    - require:
      - pkg: createrepo

/usr/local/cntv/yumSync/cntvInternalRepoSync.list:
  file.managed:
    - source: salt://project/yumRepo/files/cntvInternalRepoSync.list
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
