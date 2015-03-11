rsyslog:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
      - file: PIDFILE in /etc/init.d/rsyslog
    - require:
      - service: syslog

syslog:
  service:
    - dead
    - enable: false

PIDFILE in /etc/init.d/rsyslog:
  file.replace:
    - name: /etc/init.d/rsyslog
    - pattern: "^PIDFILE=.*$"
    - repl: "PIDFILE=/var/run/rsyslogd.pid"
    - require:
      - pkg: rsyslog

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
