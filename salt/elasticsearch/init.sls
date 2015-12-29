##创建用户@@
elasticsearch_user:
  group.present:
    - name: elasticsearch
    - gid: 280
  user.present:
    - name: elasticsearch
    - uid: 280
    - gid: 280
    - shell: "/sbin/nologin"

elasticsearch_pkg_jdk1.8.0_60:
  pkg.latest:
    - name: jdk1.8.0_60
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"

/backup/esBackup_cmd:
  cmd.run:
    - name: "mkdir -p /backup/esBackup; chown elasticsearch.elasticsearch /backup/esBackup"
    - user: root
    - unless: "[ -d /backup/esBackup ]"

{% for role in pillar['roles'] %}
{% if pillar['elasticsearch'][role] is defined %}

elasticsearch-{{role}}-pkg:
  pkg.installed:
    - name: elasticsearch
    - version: {{ pillar['elasticsearch'][role]['pkgVersion'] }}
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"
    - require:
      - pkg: elasticsearch_pkg_jdk1.8.0_60

elasticsearch-{{role}}-dataDir:
  file.directory:
    - name: {{ pillar['elasticsearch'][role]['dataDir'] }}
    - makedirs: True
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0755
#    - recurse:
#        - user
#        - group
    - require:
      - pkg: elasticsearch-{{role}}-pkg

{% for plugin in "head-20150906", "kopf-1.5.7", "marvel-1.3.1", "whatson-0.1.3", "elasticsearch-sql-1.4.7" %}
elasticsearch-{{role}}-{{plugin}}:
  file.managed:
    - name: /usr/share/elasticsearch/{{ plugin }}.tgz
    - source: salt://elasticsearch/files/{{ plugin }}.tgz
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch-{{role}}-pkg

elasticsearch-{{role}}-{{plugin}}-cmd:
  cmd.wait:
    - name: "tar zxf /usr/share/elasticsearch/{{ plugin }}.tgz -C /usr/share/elasticsearch/plugins"
    - user: root
    - group: root
    - watch:
      - file: /usr/share/elasticsearch/{{ plugin }}.tgz
{% endfor %}

elasticsearch-{{role}}-init.d:
  file.managed:
    - name: /etc/init.d/{{role}}
    - source: salt://elasticsearch/files/elasticsearch.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
        role: {{role}}
        heapMem: {{pillar['elasticsearch'][role]['heapMem']}}

elasticsearch-{{role}}-conf:
  file.managed:
    - name: /etc/elasticsearch/{{role}}/elasticsearch.yml
{% if role == "logstash-esMonitorNode" %}
    - source: salt://elasticsearch/files/logstash-esMonitorNode.elasticsearch.yml.jinja
{% else %}
    - source: salt://elasticsearch/files/logstash-es.elasticsearch.yml.jinja
{% endif %}
    - template: jinja
    - user: root
    - group: root
    - makedirs: True
    - file_mode: 0644
    - context:
        role: {{role}}
        dataDir: {{pillar['elasticsearch'][role]['dataDir']}}
        esPort: {{pillar['elasticsearch'][role]['esPort']}}
    - require:
      - pkg: elasticsearch-{{role}}-pkg

elasticsearch-{{role}}-logging.yml:
  file.managed:
    - name: /etc/elasticsearch/{{role}}/logging.yml
    - source: salt://elasticsearch/files/logging.yml
    - template: jinja
    - user: root
    - group: root
    - file_mode: 0644
    - require:
      - pkg: elasticsearch-{{role}}-pkg

##启动服务@@
elasticsearch-{{role}}-service:
  service.running:
    - name: {{role}}
    - enable: True
    - watch:
      - pkg: elasticsearch-{{role}}-pkg

##监控服务@@
/usr/local/monit/etc/inc/elasticsearch-{{role}}-monit.cfg:
  file.managed:
    - source: salt://elasticsearch/files/elasticsearch-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - context:
        role: {{role}}
        esPort: {{pillar['elasticsearch'][role]['esPort']}}

elasticsearch-{{role}}-monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/elasticsearch-{{role}}-monit.cfg

##计划任务@@
{% if ("crontab" in grains["roles"]) %}
/usr/local/cntv/{{role}}-DailyJob.sh:
  file.managed:
    - source: salt://elasticsearch/files/{{role}}-DailyJob.sh
    - user: root
    - group: root
    - makedirs: True
    - mode: 0755

elasticsearch-{{role}}-crontab:
  file.blockreplace:
    - name: /etc/crontab
    - marker_start: "## {{role}} start ##"
    - marker_end: "## {{role}} end ##"
    - content: |
        0 1 * * * root /usr/local/cntv/{{role}}-DailyJob.sh
    - append_if_not_found: True
    - backup: '.bak'
{% endif %}

{% endif %}
{% endfor %}




