/usr/local/monit/etc/inc/api.cntv.cn-monit.cfg:
  file.managed:
    - source: salt://project/api-ctnv-cn-monit/api.cntv.cn-monit.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True