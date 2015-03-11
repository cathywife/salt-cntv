/etc/resolv.conf:
  file.managed:
    - source: salt://common/resolv/resolv.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
