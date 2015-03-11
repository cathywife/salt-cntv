####单机多实例配置@@

##pillar名称@@
logstash:
{% if grains['roles'] is defined %}

{% if 'logstash-indexerSyslog' in grains['roles'] %}
  logstash-indexerSyslog:
    redisIp: "10.64.0.3"
    redisPort: "6380"
    redisKey: "logstash:syslog"
    initConf: |
      JAVACMD=/usr/bin/java
      LS_HOME=/var/lib/logstash
      LS_HEAP_SIZE="{{(grains['mem_total']*0.2)|round|int}}m"
      #LS_JAVA_OPTS="-Djava.io.tmpdir=${LS_HOME}"
      LS_JAVA_OPTS="-Xmx{{(grains['mem_total']*0.2)|round|int}}m -Djava.io.tmpdir=${LS_HOME}"
      LS_WORKER_THREADS=2
      #LS_PIDFILE=/var/run/logstash.pid
      #LS_USER=logstash
      #LS_LOG_FILE=/var/log/logstash/logstash-web.log
      #LS_USE_GC_LOGGING="true"
      LS_CONF_DIR=/etc/logstash/logstash-indexerSyslog.conf
      LS_OPEN_FILES=65535
      LS_NICE=0
{% endif %}

{% if 'logstash-indexerBeaver' in grains['roles'] %}
  logstash-indexerBeaver:
    redisIp: "10.64.0.3"
    redisPort: "6380"
    redisKey: "logstash:beaver"
    initConf: |
      JAVACMD=/usr/bin/java
      LS_HOME=/var/lib/logstash
      LS_HEAP_SIZE="{{(grains['mem_total']*0.5)|round|int}}m"
      #LS_JAVA_OPTS="-Djava.io.tmpdir=${LS_HOME}"
      LS_JAVA_OPTS="-Xmx{{(grains['mem_total']*0.5)|round|int}}m -Djava.io.tmpdir=${LS_HOME}"
      LS_WORKER_THREADS=4
      #LS_PIDFILE=/var/run/logstash.pid
      #LS_USER=logstash
      #LS_LOG_FILE=/var/log/logstash/logstash-web.log
      #LS_USE_GC_LOGGING="true"
      LS_CONF_DIR=/etc/logstash/logstash-indexerBeaver.conf
      LS_OPEN_FILES=65535
      LS_NICE=0
{% endif %}

{% endif %}
