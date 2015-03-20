####单机多实例配置@@
beaver:
{% if grains['roles'] is defined %}

{% if ("openLDAP-slave" in grains["roles"]) %}
  openLDAP:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:syslog
      logstash_version: 1
      
      [/var/log/ldap.log]
      type: openLdapSyslog
      tags: openLdapSyslog
{% endif %}

{% if "syslogCenter" in grains["roles"] %}
  syslogCenter:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:syslog
      logstash_version: 1
      
      [/var/log/rsyslog/messages.log]
      type: mySyslog
      tags: syslog
{% endif %}

{% if "saltMaster" in grains["roles"] %}
  saltMaster:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:syslog
      logstash_version: 1
      
      [/var/log/salt/master]
      multiline_regex_after: (^\s+File.*, line \d+, in)
      multiline_regex_before: (^Traceback \(most recent call last\):)|(^\s+File.*, line \d+, in)|(^\w+Error: )|(^UnicodeDecodeError: )
      type: saltLog
      tags: saltLog, saltLogMaster
{% endif %}

{% if "api.cntv.cn-web" in grains["roles"] %}
  api.cntv.cn-web:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      
      [/usr/local/apache2/logs/api.cntv.cn-access_log_*]
      type: apiWebLog
      tags: apiWebLog
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}

{% endif %}

{% if ("cdnSource-img" in grains["roles"]) %}
  cdnSource-img:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      
      [/export/home/webserver/lighttpdlogs/*_access.log]
      type: cdnSourcelighttpd
      tags: cdnSource-img
{% endif %}

{% if ("cdnSource-page" in grains["roles"]) %}
  cdnSource-page:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      
      [/export/home/webserver/apachelogs/*-access_log]
      type: cdnSourceapache
      tags: cdnSource-page
{% endif %}

{% if ("beaver-flvSource" in grains["roles"]) and ("flvSource-thirdParty" in grains["roles"]) %}
  beaver-flvSource:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      
      [/export/home/webserver/nginxlogs/*_access.log]
      type: COMBINEDAPACHELOG
      tags: flvSource,flvSource-thirdParty
{% endif %}

{% if ("beaver-flvSource" in grains["roles"]) and ("flvSource" in grains["roles"]) %}
  beaver-flvSource:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      
      [/export/home/webserver/nginxlogs/*_access.log]
      type: COMBINEDAPACHELOG
      tags: flvSource
{% endif %}

{% endif %}