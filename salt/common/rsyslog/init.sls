rsyslog:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
{% if grains['osmajorrelease'] != "7" %}
      - file: PIDFILE in /etc/init.d/rsyslog
{% endif %}
    - require:
      - service: syslog

syslog:
  service:
    - dead
    - enable: false


{% if grains['osmajorrelease'] != "7" %}
PIDFILE in /etc/init.d/rsyslog:
  file.replace:
    - name: /etc/init.d/rsyslog
    - pattern: "^PIDFILE=.*$"
    - repl: "PIDFILE=/var/run/syslogd.pid"
    - require:
      - pkg: rsyslog

PIDFILE in /etc/logrotate.d/syslog:
  file.replace:
    - name: /etc/logrotate.d/syslog
    - pattern: "cat /var/run/rsyslogd.pid"
    - repl: "cat /var/run/syslogd.pid"
    - require:
      - pkg: rsyslog
{% endif %}

/etc/rsyslog.conf:
  file.managed:
{% if "syslogCenter" in pillar['roles'] %}
    - source: salt://common/rsyslog/rsyslog_adminServer.conf
{% else %}
    - source: salt://common/rsyslog/rsyslog.conf
{% endif %}
    - user: root
    - group: root
    - mode: 664
