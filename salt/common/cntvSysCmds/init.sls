/usr/local/cntv:
  file.recurse:
    - source: salt://common/cntvSysCmds/files
    - exclude_pat: E@\.svn
    - user: root
    - group: root
    - file_mode: 0755
    - dir_mode: 0755
    - makedirs: True
    - order: 1