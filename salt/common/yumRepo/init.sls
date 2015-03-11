/etc/yum.repos.d/cntvInternal.repo:
  file.managed:
    - source: salt://common/yumRepo/cntvInternal.repo
    - user: root
    - group: root
    - mode: 664
    - order: 1

yumRepo_mkCache:
  cmd.wait:
    - name: yum makecache
    - user: root
    - timeout: 45
    - watch:
      - file: /etc/yum.repos.d/cntvInternal.repo