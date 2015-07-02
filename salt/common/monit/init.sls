include:
  - common.baseHosts

/usr/local/monit/bin/monit:
  file.managed:
    - source: salt://common/monit/bin/monit_5.12.bin
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True

/usr/local/monit/etc/monitrc:
  file.managed:
    - source: salt://common/monit/etc/monitrc.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

/root/.monit.id:
  file.managed:
    - source: salt://common/monit/etc/.monit.id.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

/usr/local/monit/etc/inc:
  file.directory:
    - makedirs: True
    - clean: True

/usr/local/monit/etc/inc/system.cfg:
  file.managed:
    - source: salt://common/monit/etc/inc/system.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - require:
      - file: /usr/local/monit/etc/inc

monit_start:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    #- unless: "`which killall` -0 monit"
    - watch:
      - file: /usr/local/monit/bin/monit
      - file: /usr/local/monit/etc/monitrc
      - file: /usr/local/monit/etc/inc/system.cfg
      - file: /root/.monit.id