/usr/local/monit/etc/inc/api.cntv.cn-web.cfg:
  file.managed:
    - source: salt://project/api-cntv-cn-web/api.cntv.cn-web.cfg.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 700
    - makedirs: True