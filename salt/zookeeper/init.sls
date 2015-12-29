####单机单实例配置开始@@

##创建用户@@
zookeeper_user:
  user.present:
    - name: zookeeper
    - shell: "/sbin/nologin"

##软件包安装@@
zookeeper_pkg_jdk1.8.0_60:
  pkg.latest:
    - name: jdk1.8.0_60
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"

zookeeper_tgz:
  file.managed:
    - name: /usr/local/zookeeper-3.4.6.tar.gz
    - source: salt://zookeeper/files/zookeeper-3.4.6.tar.gz
    - user: zookeeper
    - group: zookeeper
    - makedirs: True
    - mode: 0755

zookeeper_install:
  cmd.wait:
    - name: tar zxf /usr/local/zookeeper-3.4.6.tar.gz; ln -s /usr/local/zookeeper-3.4.6 zookeeper; chown zookeeper.zookeeper /usr/local/zookeeper* -R
    - user: root
    - group: root
    - cwd: /usr/local
    - watch:
      - file: zookeeper_tgz

##files目录下文件@@
zookeeper_dataDir:
  file.directory:
    - name: /data/zookeeper
    - makedirs: True
    - user: zookeeper
    - group: zookeeper
    - mode: 0755

#调整java heap内存，环境变量，退出状态码等
/usr/local/zookeeper/bin/zkServer.sh:
  file.managed:
    - source: salt://zookeeper/files/zkServer.sh
    - user: zookeeper
    - group: zookeeper
    - makedirs: True
    - mode: 0755
    - require:
      - cmd: zookeeper_install
      - user: zookeeper_user

/usr/local/zookeeper/conf/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/files/zoo.cfg.jinja
    - template: jinja
    - user: zookeeper
    - group: zookeeper
    - makedirs: True
    - mode: 0755
    - require:
      - cmd: zookeeper_install
      - user: zookeeper_user

/etc/init.d/zookeeper:
  file.managed:
    - source: salt://zookeeper/files/zookeeper.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755

##修改配置@@
/data/zookeeper/myid:
  file.managed:
    - source: salt://zookeeper/files/myid.jinja
    - template: jinja
    - user: zookeeper
    - group: zookeeper
    - makedirs: True
    - mode: 0755
    - require:
      - file: zookeeper_dataDir

##启动服务@@
zookeeper_start:
  service.running:
    - name: zookeeper
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/zookeeper/conf/zoo.cfg
      - file: /data/zookeeper/myid
      - file: /usr/local/zookeeper/bin/zkServer.sh

##监控服务@@
/usr/local/monit/etc/inc/zookeeper.cfg:
  file.managed:
    - source: salt://zookeeper/files/zookeeper-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

zookeeper_monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/zookeeper.cfg
