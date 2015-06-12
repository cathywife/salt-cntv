####单机多实例配置开始@@
crontab:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

##添加自定义变量@@
  rootCrontab:
{% if ("logstash-esMonitorNode" in grains["roles"]) and ("crontab" in grains["roles"]) %}
    logstash-esMonitorNode: |
      0 1 * * * root /usr/local/cntv/elasticsearchMonitorDayJob.sh
{% endif %}
{% if ("logstash-esNode" in grains["roles"]) and ("crontab" in grains["roles"]) %}
    logstash-esNode: |
      0 1 * * * root /usr/local/cntv/elasticsearchDayJob.sh
{% endif %}
{% if "yumRepo" in grains["roles"] %}
    yumRepo: |
      23 1-4 * * * root /usr/local/cntv/yumSync/rsync.sh
              */10 * * * * root /usr/local/cntv/yumSync/cntvInternalRepoSync.sh
{% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}