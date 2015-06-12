####单机单实例配置@@
hosts:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

  baseHosts: |
    10.70.58.196	saltMaster
            10.70.63.131	centralControl
  {% if 'logstash' in grains['roles'] %}
  roleHosts: |
    {{ salt['cmd.run']('/usr/bin/curl http://saltMaster/saltApi.php?role=logstash 2> /dev/null |sed "2,$ s/^/            /g"') }}
  {% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}