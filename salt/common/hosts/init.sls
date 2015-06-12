{% for name in "logstash-esNode","logstash-esSearchNode","logstash-esMonitorNode" %}
{% if name in pillar["roles"] %}
{{ name }}_hosts:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "## {{ name }} start ##"
    - marker_end: "## {{ name }} end ##"
    - content: |
        {{ pillar["hosts"]["roleHosts"] }}
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