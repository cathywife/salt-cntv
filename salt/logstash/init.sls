####单机多实例公共配置@@

##软件包安装@@
logstash_pkg_jdk1.8.0_60:
  pkg.installed:
    - name: jdk1.8.0_60
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"
logstash_pkg:
  pkg.installed:
    - names:
      - logstash
    - version: 1.5.4-1
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"
    - require:
      - pkg: logstash_pkg_jdk1.8.0_60

##拷贝files目录下文件@@
/etc/logstash:
  file.recurse:
    - source: salt://logstash/files/etc
    - exclude_pat: E@\.svn
    - user: root
    - group: root
    - file_mode: 0644
    - dir_mode: 0755
    - makedirs: True

####单机多实例非公共配置循环@@

{% for role in pillar['roles'] %}
{% if pillar['logstash'][role] is defined %}
/etc/logstash/{{role}}.conf:
  file.managed:
    - source: salt://logstash/files/{{role}}.conf.jinja
    - template: jinja
    - user: logstash
    - group: root
    - mode: 0755
    - require:
      - pkg: logstash_pkg
/etc/init.d/{{ role }}:
  file.managed:
    - source: salt://logstash/files/logstash.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
      role: {{role}}
/etc/sysconfig/{{ role }}:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: logstash:{{role}}:initConf
    - require:
      - pkg: logstash_pkg

##启动服务@@
logstash_{{role}}_service:
  service.running:
    - name: {{ role }}
    - enable: True
    - timeout: 15
    - watch:
      - file: /etc/logstash/{{role}}.conf

##监控服务@@
/usr/local/monit/etc/inc/{{ role }}.cfg:
  file.managed:
    - source: salt://logstash/files/logstash-indexer-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - context:
      role: {{role}}

{{ role }}_monit:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    - watch:
      - file: /usr/local/monit/etc/inc/{{ role }}.cfg

{% endif %}
{% endfor %}