####单机多实例公共配置@@

##系统用户@@
beaver:
  user.present:
    - home: "/usr/lib/python2.6/site-packages/beaver"
    - shell: "/sbin/nologin"

##软件包安装@@
beaver_remove:
  cmd.run:
    - name: 'rpm -e python-beaver-31-1; rpm -e Beaver-33.3.0-1'
    - user: root
    - onlyif: 'rpm -qa |grep "python-beaver-31-1\|Beaver-33.3.0-1"'

beaver_pkg:
  pkg.installed:
    - names:
      - python26-argparse
      - python26-daemon
      - python-conf_d
      - python-glob2
      - python-beaver
    - fromrepo: "cntvInternal,epel,CentOS-Base,CentOS-Update"
    - require:
      - user: beaver

{% if 'CentOS-5' in grains['osfinger'] %}
beaver_pythonToPython26:
  cmd.run:
    - name: 'sed -i "s/^#\!\/usr\/bin\/python$/#\!\/usr\/bin\/python26/g" /usr/bin/beaver'
    - user: root
    - onlyif: '[ `grep "^#\!/usr/bin/python$" /usr/bin/beaver` ]'
    - require:
      - pkg: beaver_pkg
{% endif %}

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

####单机多实例非公共配置循环@@
{% for role in pillar['roles'] %}
{% if pillar['beaver'][role] is defined %}
/etc/beaver/{{role}}.conf:
  file.managed:
    - user: beaver
    - group: root
    - file_mode: 0644
    - contents_pillar: beaver:{{role}}:mainConf
    - require:
      - pkg: beaver_pkg
      - file: /etc/beaver
/etc/init.d/beaver-{{role}}:
  file.managed:
    - source: salt://beaver/files/beaver.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
      role: {{role}}
beaver_{{role}}_service:
  service.running:
    - name: beaver-{{ role }}
    - enable: True
    - timeout: 15
    - watch:
      - file: /etc/beaver/{{role}}.conf

##监控服务@@
/usr/local/monit/etc/inc/beaver-{{ role }}.cfg:
  file.managed:
    - source: salt://beaver/files/beaver-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - context:
      role: {{role}}

beaver_monit:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    - watch:
      - file: /usr/local/monit/etc/inc/beaver-{{ role }}.cfg

{% endif %}
{% endfor %}