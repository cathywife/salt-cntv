####单机多实例公共配置@@

##系统用户@@
beaver:
  user.present:
    - home: "/usr/lib/python2.6/site-packages/beaver"
    - shell: "/sbin/nologin"

##软件包安装@@
{% if 'CentOS-6' in grains['osfinger'] %}
{% set pkgs = [ "python-argparse", "python-zmq", "python-daemon" ] %}
{% elif 'CentOS-5' in grains['osfinger'] %}
{% set pkgs = [ "python26-argparse", "python26-zmq" ] %}
beaver_pythonToPython26:
  cmd.run:
    - name: 'sed -i "s/^#\!\/usr\/bin\/python$/#\!\/usr\/bin\/python26/g" /usr/bin/beaver'
    - user: root
    - onlyif: '[ `grep "^#\!/usr/bin/python$" /usr/bin/beaver` ]'
    - require:
      - pkg: beaver_pkg
{% endif %}
beaver_pkg:
  pkg.installed:
    - names:
      - zeromq-devel
      {% for pkg in pkgs %}
      - {{pkg}}
      {% endfor %}
    - fromrepo: "cntvInternal,epel,CentOS-Base,CentOS-Update"
    - skip_verify: True
    - require:
      - pkg: beaver_pkg2
beaver_pkg2:
  pkg.installed:
    - sources:
      - python-beaver: salt://beaver/files/python-beaver-31-1.noarch.rpm
      - python-conf_d: salt://beaver/files/python-conf_d-0.0.4-1.noarch.rpm
      - python-glob2: salt://beaver/files/python-glob2-0.4.1-1.noarch.rpm
      - python-redis: salt://beaver/files/python-redis-2.10.1-1.noarch.rpm
      {% if 'CentOS-5' in grains['osfinger'] %}
      - python26-daemon: salt://beaver/files/python26-daemon-1.5.2-1.sdl5.noarch.rpm
      - python26-lockfile: salt://beaver/files/python26-lockfile-0.8-3.sdl5.noarch.rpm
      {% endif %}
    - skip_verify: True

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
{% endif %}
{% endfor %}