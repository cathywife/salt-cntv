/etc/profile.d/zz_hist.sh:
  file.managed:
    - source: salt://common/cmdHistoryAudit/zz_hist.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/cntv/sys_changeAuditLogPerm.sh:
  file.managed:
    - source: salt://common/cmdHistoryAudit/sys_changeAuditLogPerm.sh
    - user: root
    - group: root
    - mode: 755

HISTTIMEFORMAT in /etc/profile:
  file.replace:
    - name: /etc/profile
    - pattern: '^export HISTTIMEFORMAT=.*$'
    - repl: ''
    - require:
      - file: /etc/profile.d/zz_hist.sh