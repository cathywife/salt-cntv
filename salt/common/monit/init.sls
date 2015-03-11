/usr/local/monit/bin/monit:
  file.managed:
    - source: salt://common/monit/bin/monit_5.8.bin
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

/usr/local/monit/etc/inc/system.cfg:
  file.managed:
    - source: salt://common/monit/etc/inc/system.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

{% if "yumRepo" in pillar['roles'] %}
/usr/local/monit/etc/inc/yumRepo.cfg:
  file.managed:
    - source: salt://common/monit/etc/inc/yumRepo.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
{% endif %}

monit_start:
  cmd.wait:
    - name: killall -9 monit; /usr/local/monit/bin/monit -c /usr/local/monit/etc/monitrc
    #- unless: "`which killall` -0 monit"
    - watch:
      - file: /usr/local/monit/bin/monit
      - file: /usr/local/monit/etc/monitrc
      - file: /usr/local/monit/etc/inc/system.cfg
      {% if "yumRepo" in pillar['roles'] %}
      - file: /usr/local/monit/etc/inc/yumRepo.cfg
      {% endif %}