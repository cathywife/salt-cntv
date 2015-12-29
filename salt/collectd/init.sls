####单机单实例配置开始@@

##软件包安装@@
collectd_pkg:
  pkg.latest:
    - name: collectd

##修改配置@@
/etc/collectd.conf:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: collectd:mainConf
    - require:
      - pkg: collectd_pkg

##启动服务@@
collectd_service:
  service.running:
    - name: collectd
    - enable: True
    - watch:
      - pkg: collectd_pkg
      - file: /etc/collectd.conf
