rsync:
  pkg:
    - installed

/etc/rsyncd_salt.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - order: 100

/etc/rsyncd_salt.secrets:
  file.managed:
    - user: root
    - group: root
    - mode: 0400
    - order: 100

{% if "admin-svnServer" in pillar["roles"] %}
rsync_admin-svnServer:
  file.blockreplace:
    - name: /etc/rsyncd_salt.conf
    - marker_start: "## saltstack start ##"
    - marker_end: "## saltstack end ##"
    - append_if_not_found: True
    - backup: '.bak'
    - content: |
        max connections=36000
        use chroot=no
        log file=/var/log/rsyncd.log
        pid file=/var/run/rsyncd.pid
        lock file=/var/run/rsyncd.lock
        
        [svn]
                uid             = apache
                gid             = apache
                path            = /data/svn
                ignore errors   = yes
                read only       = no
                hosts allow     = 10.70.63.131, 10.70.63.228, 10.70.58.196
                auth users      = user
                secrets file    = /etc/rsyncd_salt.secrets
                hosts deny      = *
        [jenkins]
                uid             = root
                gid             = root
                path            = /data/jenkins
                ignore errors   = yes
                read only       = no
                hosts allow     = 10.70.63.131, 10.70.63.228, 10.70.58.196
                auth users      = user
                secrets file    = /etc/rsyncd_salt.secrets
                hosts deny      = *
    - order: 200

rsync_admin-svnServer_passwd:
  file.blockreplace:
    - name: /etc/rsyncd_salt.secrets
    - marker_start: "## saltstack start ##"
    - marker_end: "## saltstack end ##"
    - append_if_not_found: True
    - backup: '.bak'
    - content: |
        {{ pillar["myShadow"]["rsyncSalt"]["secretString"] }}
    - order: 200

rsync_cmdRsyncSalt:
  cmd.wait:
    - name: /usr/bin/rsync --daemon --config=/etc/rsyncd_salt.conf --port 874
    - user: root
    - watch:
      - file: /etc/rsyncd_salt.conf
      - file: /etc/rsyncd_salt.secrets
{% endif %}