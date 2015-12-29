####单机单实例配置开始@@

##软件包安装@@
docker_pkg:
  pkg.latest:
    - name: docker-engine
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"

##修改配置@@


##启动服务@@
docker_service:
  service.running:
    - name: docker
    - enable: True
    - watch:
      - pkg: docker_pkg

##监控服务@@
/usr/local/monit/etc/inc/docker.cfg:
  file.managed:
    - source: salt://docker/files/docker-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

docker_monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/docker.cfg