{% for name in "logstash-esNode","logstash-esSearchNode" %}
{% if name in pillar["roles"] %}
{{ name }}_hosts:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "## {{ name }} start ##"
    - marker_end: "## {{ name }} end ##"
    - content: |
        {%- if name == "logstash-esNode" or name == "logstash-esSearchNode" %}
        10.64.1.223	logstash-esMonitorNode-1
        10.64.0.242	logstash-esNode-5
        10.64.0.243	logstash-esNode-6
        10.64.1.174	logstash-esNode-1
        10.64.1.175	logstash-esNode-2
        10.64.1.176	logstash-esNode-3
        10.64.1.177	logstash-esNode-4
        10.64.0.2	logstash-esSearchNode-1
        10.64.0.4	logstash-esSearchNode-2
        {%- endif %}
    - append_if_not_found: True
    - backup: '.bak'
{% endif %}
{% endfor %}

{% if pillar["hostname"] is iterable %}
{% for hostname in pillar["hostname"] %}
{{hostname}}_hostname_file:
  file.replace:
    - name: /etc/sysconfig/network
    - pattern: "^HOSTNAME=.*$"
    - repl: "HOSTNAME={{hostname}}"
{{hostname}}_hostname_cmd:
  cmd.wait:
    - name: "hostname {{hostname}}"
    - user: root
    - watch:
      - file: {{hostname}}_hostname_file
{% endfor %}
{% endif %}