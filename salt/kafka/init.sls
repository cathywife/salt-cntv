####单机单实例配置开始@@

##创建用户@@
kafka_user:
  user.present:
    - name: kafka
    - shell: "/sbin/nologin"

##软件包安装@@
kafka_pkg_jdk1.8.0_60:
  pkg.latest:
    - name: jdk1.8.0_60
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"

kafka_tgz:
  file.managed:
    - name: /usr/local/kafka_2.10-0.8.2.2.tgz
    - source: salt://kafka/files/kafka_2.10-0.8.2.2.tgz
    - user: kafka
    - group: kafka
    - makedirs: True
    - mode: 0755

kafka_install:
  cmd.wait:
    - name: tar zxf /usr/local/kafka_2.10-0.8.2.2.tgz; ln -s /usr/local/kafka_2.10-0.8.2.2 kafka; chown kafka.kafka /usr/local/kafka* -R
    - user: root
    - group: root
    - cwd: /usr/local
    - watch:
      - file: kafka_tgz

##files目录下文件@@
kafka_dataDir:
  file.directory:
    - name: /data/kafka/v1
    - makedirs: True
    - user: kafka
    - group: kafka
    - mode: 0755

kafka_logDir:
  file.directory:
    - name: /usr/local/kafka/logs
    - makedirs: True
    - user: kafka
    - group: kafka
    - mode: 0755
    - require:
      - cmd: kafka_install

/etc/init.d/kafka:
  file.managed:
    - source: salt://kafka/files/kafka.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755

/usr/local/kafka/config/server.properties:
  file.managed:
    - source: salt://kafka/files/server.properties.jinja
    - template: jinja
    - user: kafka
    - group: kafka
    - makedirs: True
    - mode: 0755
    - require:
      - cmd: kafka_install
      - user: kafka_user

##修改配置@@
KAFKA_HEAP_OPTS in /usr/local/kafka/bin/kafka-server-start.sh:
  file.replace:
    - name: /usr/local/kafka/bin/kafka-server-start.sh
    - pattern: "KAFKA_HEAP_OPTS=.*$"
    - repl: 'KAFKA_HEAP_OPTS="-Xmx1024m -Xms1024m"'
    - require:
      - cmd: kafka_install

JMX_PORT in /usr/local/kafka/bin/kafka-server-start.sh:
  file.blockreplace:
    - name: /usr/local/kafka/bin/kafka-server-start.sh
    - marker_start: "## JMX_PORT start ##"
    - marker_end: "## JMX_PORT end ##"
    - content: "export JMX_PORT=9999"
    - prepend_if_not_found: True
    - backup: '.bak'
    - require:
      - cmd: kafka_install

##启动服务@@
kafka_start:
  service.running:
    - name: kafka
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/kafka/config/server.properties
      - file: KAFKA_HEAP_OPTS in /usr/local/kafka/bin/kafka-server-start.sh

##监控服务@@
/usr/local/monit/etc/inc/kafka.cfg:
  file.managed:
    - source: salt://kafka/files/kafka-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

kafka_monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/kafka.cfg
