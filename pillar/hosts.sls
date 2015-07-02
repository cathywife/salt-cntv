####单机单实例配置@@
hosts:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

  baseHosts: |
    10.70.58.196	saltMaster
            10.70.63.131	centralControl

  {% for name in grains['roles'] %}
  {{ name }}_roleHosts: |
    {{ salt['cmd.run']('/usr/bin/curl http://saltMaster/saltApi.php?role='+name+' 2> /dev/null |sed "2,$ s/^/            /g"') }}
  {% endfor %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}