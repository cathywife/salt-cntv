include:
  - common.baseHosts

/tmp/.monit.state:
  file.absent

/usr/local/monit/bin/monit:
  file.managed:
    - source: salt://common/monit/bin/monit_5.15.bin
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

/etc/init.d/monit:
  file.managed:
    - source: salt://common/monit/files/monit.init.d
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

#/root/.monit.id:
#  file.managed:
#    - source: salt://common/monit/etc/.monit.id.jinja
#    - template: jinja
#    - user: root
#    - group: root
#    - mode: 600
#    - makedirs: True

#/usr/local/monit/etc/inc:
#  file.directory:
#    - makedirs: True
#    - clean: True

/usr/local/monit/etc/inc/system.cfg:
  file.managed:
    - source: salt://common/monit/etc/inc/system.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
#    - require:
#      - file: /usr/local/monit/etc/inc

#monit_start:
#  cmd.wait:
#    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
#    #- unless: "`which killall` -0 monit"
#    - watch:
#      - file: /usr/local/monit/bin/monit
#      - file: /usr/local/monit/etc/monitrc
#      - file: /usr/local/monit/etc/inc/system.cfg
#      - file: /tmp/.monit.state

monit_service:
  service.running:
    - name: monit
    - enable: True
    - timeout: 15
    - watch:
      - file: /usr/local/monit/bin/monit
      - file: /usr/local/monit/etc/inc/system.cfg
      - file: /usr/local/monit/etc/monitrc