####单机单实例配置@@

##软件包安装@@
svnServer_pkg:
  pkg.latest:
    - names:
      - httpd
      - httpd-devel
      - subversion
      - mod_dav_svn

##修改文件;修改配置@@
{% for repo in pillar['svnServer'] %}

#创建目录@@
{{ pillar['svnServer'][repo]['dataDir'] }}:
  file.directory:
    - user: apache
    - group: apache
    - mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: svnServer_pkg

#创建认证文件@@
/data/svn/authz:
  file.managed:
    - user: apache
    - group: apache
    - file_mode: 0644
    - contents_pillar: svnServer:{{ repo }}:authzConf
    - require:
      - pkg: svnServer_pkg

#创建svn@@
svnadmin create {{ repo }}:
  cmd.run:
    - name: 'svnadmin create {{ repo }} && sed -i "s/^# authz-db = authz/authz-db = \/data\/svn\/authz/g" {{ pillar['svnServer'][repo]['dataDir'] }}/conf/svnserve.conf'
    - user: root
    - unless: 'ls {{ pillar['svnServer'][repo]['dataDir'] }}/conf/svnserve.conf'
    - require:
      - pkg: svnServer_pkg

#配置apache@@
/etc/httpd/conf.d/subversion-{{ repo }}.conf:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: svnServer:{{ repo }}:mainConf
    - require:
      - pkg: svnServer_pkg
{% endfor %}

##启动服务@@
httpd_svn_service:
  service.running:
    - name: httpd
    - enable: True
    - watch:
{% for repo in pillar['svnServer'] %}
      - file: /etc/httpd/conf.d/subversion-{{ repo }}.conf
{% endfor %}