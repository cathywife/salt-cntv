cntvCms_cmdStart:
  cmd.wait:
    - name: "/usr/bin/rsyncCntvCms --daemon --config=/etc/cntvCms/rsyncd.conf --port 7878 &"
    - user: root
    - watch:
      - file: /etc/cntvCms/rsyncd.conf
      - file: /etc/cntvCms/rsyncd.secrets
    - require:
      - file: /etc/rc.local
      - pkg: rsync
      - cmd: cntvCms_cpCmd

cntvCms_cpCmd:
  cmd.run:
    - name: "cp /usr/bin/rsync /usr/bin/rsyncCntvCms"
    - unless: "/usr/bin/killall -0 rsyncCntvCms"
    - user: root
    
/etc/cntvCms/rsyncd.conf:
  file.managed:
    - source: salt://common/cntvCms/rsyncd.conf
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True

/etc/cntvCms/rsyncd.secrets:
  file.managed:
    - source: salt://common/cntvCms/rsyncd.secrets.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0400
    - makedirs: True
