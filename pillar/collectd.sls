####单机单实例配置@@

##pillar名称@@
collectd:
{% if grains['roles'] is defined %}

{% if 'collectd' in grains['roles'] %}
  mainConf: |
    Hostname "{{grains['id']}}"
    LoadPlugin interface
    LoadPlugin load
    LoadPlugin memory
    LoadPlugin network
    
    Interval 20
    
    <Plugin network>
      <Server "10.64.0.1" "25826">
{%- for eth in grains["ip4_interfaces"] %}
{%- if grains["id"] in grains["ip4_interfaces"][eth] %}
        Interface "{{eth}}"
{%- endif %}
{%- endfor %}
      </Server>
    </Plugin>
{% endif %}

{% endif %}
