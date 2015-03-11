####单机单实例配置开始@@

##软件包安装@@
nginx_pkg:
  pkg.installed:
    - name: nginx

##创建并设置目录权限@@
{% for path in "/data/www", "/data/nginxLog" %}
{{path}}:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: nginx_pkg
{% endfor %}

{% if "pypiReverseproxy" in pillar["roles"] %}
/data/nginxCache:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 0755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: nginx_pkg
{% endif %}

##拷贝files目录下文件@@
{% for file in "nginx.conf", "fastcgi_params" %}
/etc/nginx/{{file}}:
  file.managed:
    - source: salt://nginx/files/{{file}}
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 644
    - require:
      - pkg: nginx_pkg
{% endfor %}

{% for role in pillar["roles"] if not role == "base" %}
/etc/nginx/conf.d/{{role}}.conf:
  file.managed:
    - source: salt://nginx/files/conf.d/{{role}}.conf
    - user: nginx
    - group: nginx
    - mode: 644
    - require:
      - pkg: nginx_pkg
{% endfor %}

##执行命令@@
#

##修改配置@@
#

##启动服务@@
service_nginx:
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx_pkg
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/fastcgi_params
{%- for role in pillar["roles"] if not role == "base" %}
      - file: /etc/nginx/conf.d/{{role}}.conf
{%- endfor %}
