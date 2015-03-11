/etc/ssh/sshd_config:
  file.managed:
    - source: salt://common/sshd/sshd_config.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0400