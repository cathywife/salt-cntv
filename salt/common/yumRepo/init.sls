/etc/yum.repos.d/cntvInternal.repo:
  file.managed:
    - source: salt://common/yumRepo/cntvInternal.repo
    - user: root
    - group: root
    - mode: 664
    - order: 1

yumRepo_clean all:
  cmd.wait:
    - name: "yum clean all --enablerepo=cntvInternal,cntvInternal-linux"
    - user: root
    - watch:
      - file: /etc/yum.repos.d/cntvInternal.repo

#yumRepo_mkCache:
#  cmd.wait:
#    - name: yum makecache
#    - user: root
#    - timeout: 45
#    - watch:
#      - file: /etc/yum.repos.d/cntvInternal.repo
