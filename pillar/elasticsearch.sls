####单机单实例配置@@
elasticsearch:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

##定制pillar（单机单实例应使用相同变量名称）@@
{% if 'logstash-esSearchNode' in grains['roles'] %}
  logstash-esSearchNode:
    pkgVersion: "1.7.3-1"
    dataDir: "/syslog/ESdata"
    esPort: 9300
    heapMem: "{{ (grains['mem_total'] * 0.1 )|int }}m"
{% endif %}

{% if 'logstash-esNode-P10' in grains['roles'] %}
  logstash-esNode-P10:
    pkgVersion: "1.7.3-1"
    dataDir: "/syslog/ESdata"
    esPort: 9310
    heapMem: "{{ (grains['mem_total'] * 0.5 )|int }}m"
{% endif %}

{% if 'logstash-esMonitorNode' in grains['roles'] %}
  logstash-esMonitorNode:
    pkgVersion: "1.7.3-1"
    dataDir: "/syslog/ESdata"
    esPort: 9300
    heapMem: "{{ (grains['mem_total'] * 0.5 )|int }}m"
{% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}
