{% set desc = pillar["desc"][0] %}

#selinux
turnOffSelinux:
  cmd.run:
    - name: 'setenforce 0'
    - onlyif: '[ "`getenforce`" == "Enforcing" ]'
    - user: root

/etc/sysconfig/selinux:
  file.sed:
    - before: permissive|enforcing
    - after: disabled
    - limit: ^SELINUX=

#文件打开数
/etc/security/limits.conf:
  file.blockreplace:
    - marker_start: "## saltstack start ##"
    - marker_end: "## saltstack end ##"
    - append_if_not_found: True
    - backup: '.bak'
    - content: |
        *                soft    nproc           655350
        *                hard    nproc           655350
        *                soft    nofile          655350
        *                hard    nofile          655350
        {%- if desc.startswith("logstash-es") %}
        elasticsearch    -       memlock         unlimited
        {%- endif %}

#系统参数优化
/etc/sysctl.conf:
  file.blockreplace:
    - marker_start: "## saltstack start ##"
    - marker_end: "## saltstack end ##"
    - append_if_not_found: True
    - backup: '.bak'
    - content: |
        net.ipv4.tcp_fin_timeout = 30
        net.ipv4.tcp_keepalive_time = 300
        net.ipv4.tcp_syncookies = 1
        net.ipv4.tcp_tw_reuse = 1
        net.ipv4.tcp_tw_recycle = 1
        net.ipv4.ip_local_port_range = 5000    65000
        #http://mengzhuo.org/blog/linux%E4%B8%8Bredis%E5%86%85%E5%AD%98%E4%BC%98%E5%8C%96.html
        #swap_tendency = mapped_ratio/2 + distress + vm_swappiness
        vm.swappiness = 0
        {%- if desc.startswith("logstash-es") %}
        vm.max_map_count=262144
        {%- endif %}

#系统参数生效 -e:忽略错误 避免出现bug,参考:http://serverfault.com/questions/477718/sysctl-p-etc-sysctl-conf-returns-error
baseOptimize_cmdSysctl:
  cmd.wait:
    - name: /sbin/sysctl -e -p
    - user: root
    - watch:
      - file: /etc/sysctl.conf

baseOptimize_cmdUlimit:
  cmd.wait:
    - name: /bin/bash -c "ulimit -n 655350"
    - user: root
    - watch:
      - file: /etc/security/limits.conf
