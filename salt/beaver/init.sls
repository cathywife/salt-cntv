####单机多实例公共配置@@

##创建用户@@
beaver:
  user.present:
    - shell: "/sbin/nologin"

##软件包安装@@
beaver_remove:
  cmd.run:
{%- if 'CentOS-5' in grains['osfinger'] %}
    - name: 'killall beaver; rm -f /etc/beaver/*; rm -f /etc/init.d/beaver*; rm -f /usr/local/monit/etc/inc/beaver*; yum remove -y python-beaver-31-1 python26-beaver-33.3.0-1 Beaver-33.3.0-1 python-conf_d python-glob2 python-redis'
{%- else %}
    - name: 'killall beaver; rm -f /etc/beaver/*; rm -f /etc/init.d/beaver*; rm -f /usr/local/monit/etc/inc/beaver*; yum remove -y python-beaver-31-1 Beaver-33.3.0-1'
{%- endif %}
    - user: root
    - order: 1
#    - onlyif: 'rpm -qa |grep "^python-beaver\|^Beaver"'

beaver_pkg:
  pkg.latest:
    - names:
      - kafka-python
{%- if 'CentOS-5' in grains['osfinger'] %}
      - python26-argparse
      - python26-daemon
      - python26-conf_d
      - python26-glob2
      - python26-redis
      - python26-beaver
{%- else %}
      - python-argparse
      - python-daemon
      - python-conf_d
      - python-glob2
      - python-redis
      - python-beaver
      - python-setuptools
      - python-six
      - python-msgpack
{%- endif %}
    - fromrepo: "cntvInternal,epel,CentOS-Base,CentOS-Update"
    - require:
      - user: beaver

##创建并设置目录权限@@
{% for path in "/var/log/beaver", "/var/run/beaver", "/etc/beaver" %}
{{path}}:
  file.directory:
    - user: beaver
    - group: root
    - mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: beaver
{% endfor %}

##拷贝files目录下文件@@

/etc/beaver/beaver.conf:
  file.managed:
    - source: salt://beaver/files/beaver-conf.jinja
    - template: jinja
    - user: beaver
    - group: root
    - file_mode: 0644
    - require:
      - pkg: beaver_pkg
      - file: /etc/beaver

/etc/init.d/beaver:
  file.managed:
    - source: salt://beaver/files/beaver.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755

beaver_service:
  service.running:
    - name: beaver
    - enable: True
    - timeout: 15
    - watch:
      - file: /etc/beaver/beaver.conf

##监控服务@@
/usr/local/monit/etc/inc/beaver.cfg:
  file.managed:
    - source: salt://beaver/files/beaver-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

beaver_monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/beaver.cfg
