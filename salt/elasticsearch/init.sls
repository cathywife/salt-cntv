####单机单实例配置开始@@

##软件包安装@@
elasticsearch_pkg_java-1.7:
  pkg.installed:
    - name: java-1.7.0-openjdk-devel
elasticsearch-pkg:
  pkg.installed:
    - name: elasticsearch
    - sources:
      - elasticsearch: {{ pillar['elasticsearch']['pkg'] }}
    - skip_verify: True
    - require:
      - pkg: elasticsearch_pkg_java-1.7

##拷贝files目录下文件@@
{{ pillar['elasticsearch']['dataDir'] }}:
  file.directory:
    - makedirs: True
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0755
    - require:
      - pkg: elasticsearch-pkg
/usr/share/elasticsearch/plugins.tgz:
  file.managed:
    - source: {{ pillar['elasticsearch']['plugins'] }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch-pkg
/usr/local/cntv/elasticsearchDayJob.sh:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearchDayJob.sh
    - user: root
    - group: root
    - makedirs: True
    - mode: 0755
/usr/local/cntv/elasticsearchMonitorDayJob.sh:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearchMonitorDayJob.sh
    - user: root
    - group: root
    - makedirs: True
    - mode: 0755

##执行命令@@
untar plugins.tgz:
  cmd.wait:
    - name: tar zxf /usr/share/elasticsearch/plugins.tgz
    - user: root
    - group: root
    - cwd: /usr/share/elasticsearch
    - watch:
      - file: /usr/share/elasticsearch/plugins.tgz

##修改配置@@
ES_HEAP_SIZE in /etc/sysconfig/elasticsearch:
  file.replace:
    - name: /etc/sysconfig/elasticsearch
    - pattern: "^#?ES_HEAP_SIZE=.*$"
    - repl: "{{ pillar['elasticsearch']['heapMem'] }}"
    - require:
      - pkg: elasticsearch-pkg

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: elasticsearch:mainConf
    - require:
      - pkg: elasticsearch-pkg

##启动服务@@
service_elasticsearch:
  service.running:
    - name: elasticsearch
    - enable: True
    - watch:
      - pkg: elasticsearch-pkg


##监控服务@@

/usr/local/monit/etc/inc/logstash-es.cfg:
  file.managed:
    - source: salt://elasticsearch/files/logstash-es-monit.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

elasticsearch_monit:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    - watch:
      - file: /usr/local/monit/etc/inc/logstash-es.cfg