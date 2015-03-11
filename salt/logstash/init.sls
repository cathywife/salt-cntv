####单机多实例公共配置@@

##软件包安装@@
logstash_pkg_java-1.7:
  pkg.installed:
    - name: java-1.7.0-openjdk-devel
logstash_pkg:
  pkg.installed:
    - name: logstash
    - sources:
      - logstash: salt://logstash/files/logstash-1.4.2-1_2c0f5a1.noarch.rpm
    - skip_verify: True
    - require:
      - pkg: logstash_pkg_java-1.7
logstashContrib_pkg:
  pkg.installed:
    - name: logstash-contrib
    - sources:
      - logstash-contrib: salt://logstash/files/logstash-contrib-1.4.2-1_efd53ef.noarch.rpm
    - skip_verify: True
    - require:
      - pkg: logstash_pkg_java-1.7

##拷贝files目录下文件@@
/etc/logstash:
  file.recurse:
    - source: salt://logstash/files/etc
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
logstash_{{role}}_service:
  service.running:
    - name: {{ role }}
    - enable: True
    - timeout: 15
    - watch:
      - file: /etc/logstash/{{role}}.conf
{% endif %}
{% endfor %}