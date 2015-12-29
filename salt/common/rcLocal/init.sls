/etc/rc.local:
  file.blockreplace:
    - marker_start: "## saltstack start ##"
    - marker_end: "## saltstack end ##"
    - append_if_not_found: True
    - backup: '.bak'
    - content: |
        {%- if "weibo" in pillar["roles"] %}
        /usr/bin/rsyncCntvCms --daemon --config=/etc/cntvCms/rsyncd.conf --port 7878
        {%- endif %}
        {%- if "admin-svnServer" in pillar["roles"] %}
        /usr/bin/rsync --daemon --config=/etc/rsyncd_salt.conf --port 874
        {%- endif %}
        {%- if "cdh5" in pillar["roles"] %}
        echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag
        {%- endif %}
        #

/etc/rc.d/rc.local:
  file.symlink:
    - target: /etc/rc.local
    - force: True