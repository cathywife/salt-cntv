####单机多实例配置@@
beaver:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

{% if ("openLDAP-slave" in grains["roles"]) %}
  openLDAP:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:syslog
      logstash_version: 1
      hostname: {{ grains["id"] }}
      
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
      hostname: {{ grains["id"] }}
      
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
      hostname: {{ grains["id"] }}
      
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
      hostname: {{ grains["id"] }}
      
      [/usr/local/apache2/logs/*-access_log_*]
      type: apiWebLog
      tags: api.cntv.cn-web
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
      [/data/www/cntv_api/logs/*/*/*.log]
      multiline_regex_before: (^LogInfo:)|(^SpendTime:)|(^Statu:)|(^Type:)|(^Service:)|(^$)
      type: apiAppLog
      tags: api.cntv.cn-web, cntv_api
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
      [/data/www/cntv_hot/logs/*/*/*.log]
      multiline_regex_before: (^LogInfo:)|(^SpendTime:)|(^Statu:)|(^Type:)|(^Service:)|(^$)
      type: apiAppLog
      tags: api.cntv.cn-web, cntv_hot
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
      [/data/www/cntv_movie/logs/*/*/*.log]
      multiline_regex_before: (^LogInfo:)|(^SpendTime:)|(^Statu:)|(^Type:)|(^Service:)|(^$)
      type: apiAppLog
      tags: api.cntv.cn-web, cntv_movie
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
      hostname: {{ grains["id"] }}
      
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
      hostname: {{ grains["id"] }}
      
      [/export/home/webserver/apachelogs/*-access_log]
      type: cdnSourceapache
      tags: cdnSource-page
{% endif %}

{% if ("apiCmsInterface-L1" in grains["roles"]) %}
  apiCmsInterface-L1:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      hostname: {{ grains["id"] }}
      
      [/usr/local/newsapp/tomcat/xinwenlogs/xinwenSkip.log]
      type: apiCmsInterfaceLog
      tags: apiCmsInterface-L1
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
      
      [/usr/local/newsapp/tomcat/xinwenlogs/xinwenJianKong.log]
      type: apiCmsInterfaceLogNew
      tags: apiCmsInterface-L1
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
{% endif %}

{% if ("tv.cntv.cn-web" in grains["roles"]) %}
  tv.cntv.cn-web:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      hostname: {{ grains["id"] }}
      
      [/usr/local/apache2/logs/*-access_log_*]
      type: tvWebLog
      tags: tv.cntv.cn-web
{%- for location in grains['location'] %}
      add_field: location, {{location}}
{%- endfor %}
{% endif %}

{% if ("beaver-flvSource" in grains["roles"]) and ("flvSource-thirdParty" in grains["roles"]) %}
  beaver-flvSource:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      hostname: {{ grains["id"] }}
      
      [/export/home/webserver/nginxlogs/*_access.log]
      type: COMBINEDAPACHELOG
      tags: flvSource,flvSource-thirdParty
{% elif ("beaver-flvSource" in grains["roles"]) and ("flvSource" in grains["roles"]) %}
  beaver-flvSource:
    mainConf: |
      [beaver]
      transport: redis
      redis_url: redis://10.64.0.3:6380/0
      redis_namespace: logstash:beaver
      logstash_version: 1
      hostname: {{ grains["id"] }}
      
      [/export/home/webserver/nginxlogs/*_access.log]
      type: COMBINEDAPACHELOG
      tags: flvSource
{% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}