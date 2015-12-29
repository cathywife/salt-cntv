{% for name in "logstash","cdh5" %}
{% if name in pillar["roles"] %}
{{ name }}_hosts:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "## {{ name }} start ##"
    - marker_end: "## {{ name }} end ##"
    - content: |
        {{ pillar["hosts"][name+"_roleHosts"] }}
    - append_if_not_found: True
    - backup: '.bak'
{% endif %}
{% endfor %}

{% if pillar["hostname"] is iterable %}
{% for hostname in pillar["hostname"] %}
{{hostname}}_hostname_file1:
  file.replace:
    - name: /etc/sysconfig/network
    - pattern: "^HOSTNAME=.*$"
    - repl: "HOSTNAME={{hostname}}"

{{hostname}}_hostname_file2:
  file.managed:
    - name: /etc/hostname
    - user: root
    - group: root
    - file_mode: 644
    - contents: {{hostname}}

{{hostname}}_hostname_file3:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "## hostname start ##"
    - marker_end: "## hostname end ##"
    - content: |
        127.0.0.1   {{hostname}}
    - append_if_not_found: True
    - backup: '.bak'

{{hostname}}_hostname_cmd:
  cmd.wait:
    - name: "hostname {{hostname}}"
    - user: root
    - watch:
      - file: {{hostname}}_hostname_file1
      - file: {{hostname}}_hostname_file2
      - file: {{hostname}}_hostname_file3
{% endfor %}
{% endif %}