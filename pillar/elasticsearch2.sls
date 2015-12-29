elasticsearch2:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

##定制pillar（单机单实例应使用相同变量名称）@@
{% if 'es2-test-client' in grains['roles'] %}
  es2-test-client:
    pkgVersion: "2.1.0-1"
    dataDir: "/data/ESdata"
    esPort: 9300
    heapMem: "{{ (grains['mem_total'] * 0.3 )|int }}m"
{% endif %}

{% if 'es2-test-data' in grains['roles'] %}
  es2-test-data:
    pkgVersion: "2.1.0-1"
    dataDir: "/data/ESdata"
    esPort: 9310
    heapMem: "{{ (grains['mem_total'] * 0.3 )|int }}m"
{% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}