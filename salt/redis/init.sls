####单机单实例配置开始@@

##系统用户@@
redis:
  user.present:
    - home: "/var/lib/redis"
    - shell: "/sbin/nologin"

##软件包安装@@
redis_pkg:
  pkg.installed:
    - name: redis
    - fromrepo: "cntvInternal,epel"

##拷贝files目录下文件@@

{% for path in [ pillar["redis"]["pidDir"], pillar["redis"]["logDir"], pillar["redis"]["dataDir"] ~ "/" ~ pillar["redis"]["port"] ]%}
{{ path }}:
  file.directory:
    - makedirs: True
    - user: redis
    - group: root
    - dir_mode: 0755
    - require:
      - pkg: redis_pkg
      - user: redis
{% endfor %}

##修改配置@@
initConf in /etc/init.d/redis:
  file.blockreplace:
    - name: /etc/init.d/redis
    - append_if_not_found: False
    - marker_start: '. /etc/rc.d/init.d/functions'
    - marker_end: 'start() {'
    - content: |
        
        {{pillar["redis"]["initConf"]}}
        
    - require:
      - pkg: redis_pkg
/etc/redis/{{ pillar["redis"]["port"] }}.conf:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: redis:mainConf
    - require:
      - pkg: redis_pkg

##启动服务@@
redis_service:
  service.running:
    - name: redis
    - enable: True
    - watch:
      - file: /etc/redis/{{ pillar["redis"]["port"] }}.conf