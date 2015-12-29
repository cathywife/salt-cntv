##创建用户@@
elasticsearch2_user:
  group.present:
    - name: elasticsearch
    - gid: 280
  user.present:
    - name: elasticsearch
    - uid: 280
    - gid: 280
    - shell: "/sbin/nologin"

elasticsearch2_pkg_jdk1.8.0_60:
  pkg.latest:
    - name: jdk1.8.0_60
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"

/backup/esBackup_cmd:
  cmd.run:
    - name: "mkdir -p /backup/esBackup; chown elasticsearch.elasticsearch /backup/esBackup"
    - user: root
    - unless: "[ -d /backup/esBackup ]"

/usr/local/cntv/elasticsearchDayJob.sh:
  file.managed:
    - source: salt://elasticsearch2/files/elasticsearchDayJob.sh
    - user: root
    - group: root
    - makedirs: True
    - mode: 0755

/usr/local/cntv/elasticsearchMonitorDayJob.sh:
  file.managed:
    - source: salt://elasticsearch2/files/elasticsearchMonitorDayJob.sh
    - user: root
    - group: root
    - makedirs: True
    - mode: 0755

{% for role in pillar['roles'] %}
{% if pillar['elasticsearch2'][role] is defined %}

elasticsearch2-{{role}}-pkg:
  pkg.installed:
    - name: elasticsearch
    - version: {{ pillar['elasticsearch2'][role]['pkgVersion'] }}
    - fromrepo: "cntvInternal,cntvInternal-linux,epel,CentOS-Base,CentOS-Update"
    - require:
      - pkg: elasticsearch2_pkg_jdk1.8.0_60

elasticsearch2-{{role}}-dataDir:
  file.directory:
    - name: {{ pillar['elasticsearch2'][role]['dataDir'] }}
    - makedirs: True
    - user: elasticsearch
    - group: elasticsearch
    - mode: 0755
    - recurse:
        - user
        - group
    - require:
      - pkg: elasticsearch2-{{role}}-pkg

{% for plugin in "kopf-2.1.1", "elasticsearch-sql-2.1.0" %}
elasticsearch2-{{role}}-{{plugin}}:
  file.managed:
    - name: /usr/share/elasticsearch/{{ plugin }}.tgz
    - source: salt://elasticsearch2/files/{{ plugin }}.tgz
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: elasticsearch2-{{role}}-pkg

elasticsearch2-{{role}}-{{plugin}}-cmd:
  cmd.wait:
    - name: "tar zxf /usr/share/elasticsearch/{{ plugin }}.tgz -C /usr/share/elasticsearch/plugins"
    - user: root
    - group: root
    - watch:
      - file: /usr/share/elasticsearch/{{ plugin }}.tgz
{% endfor %}

elasticsearch2-{{role}}-init.d:
  file.managed:
    - name: /etc/init.d/{{role}}
    - source: salt://elasticsearch2/files/es2-elasticsearch.init.d.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - context:
        role: {{role}}
        heapMem: {{pillar['elasticsearch2'][role]['heapMem']}}

elasticsearch2-{{role}}-conf:
  file.managed:
    - name: /etc/elasticsearch/{{role}}/elasticsearch.yml
    - source: salt://elasticsearch2/files/{{role}}.elasticsearch.yml.jinja
    - template: jinja
    - user: root
    - group: root
    - makedirs: True
    - file_mode: 0644
    - context:
        role: {{role}}
        dataDir: {{pillar['elasticsearch2'][role]['dataDir']}}
        esPort: {{pillar['elasticsearch2'][role]['esPort']}}
    - require:
      - pkg: elasticsearch2-{{role}}-pkg

elasticsearch2-{{role}}-logging.yml:
  file.managed:
    - name: /etc/elasticsearch/{{role}}/logging.yml
    - source: salt://elasticsearch2/files/logging.yml
    - template: jinja
    - user: root
    - group: root
    - file_mode: 0644
    - require:
      - pkg: elasticsearch2-{{role}}-pkg

##启动服务@@
elasticsearch2-{{role}}-service:
  service.running:
    - name: {{role}}
    - enable: True
    - watch:
      - pkg: elasticsearch2-{{role}}-pkg

##监控服务@@
/usr/local/monit/etc/inc/elasticsearch2-{{role}}-monit.cfg:
  file.managed:
    - source: salt://elasticsearch2/files/es2-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - context:
        role: {{role}}
        esPort: {{pillar['elasticsearch2'][role]['esPort']}}

elasticsearch2-{{role}}-monit:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/etc/inc/elasticsearch2-{{role}}-monit.cfg

{% endif %}
{% endfor %}




