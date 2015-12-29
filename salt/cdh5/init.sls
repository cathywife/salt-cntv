####单机单实例配置开始@@

##软件包安装@@

{% if "cdh5-scmMaster" in pillar["roles"] %}
scmMaster_pkg:
  pkg.latest:
    - names:
      - oracle-j2sdk1.7
      - cloudera-manager-daemons
      - cloudera-manager-server
      - cloudera-manager-server-db-2
    - fromrepo: "cntvCdh5,epel,CentOS-Base,CentOS-Update"
{% endif %}

##拷贝files目录下文件@@

##执行命令@@
remove_/usr/bin/host:
  cmd.run:
    - name: "mv /usr/bin/host /usr/bin/host.bak"
    - user: root
    - onlyif : "[ -f /usr/bin/host ]"

##修改配置@@
scm-sshKeyPub1:
  file.touch:
    - name: /root/.ssh/authorized_keys
    - user: root
    - group: root
    - file_mode: 600
    - dir_mode: 700

scm-sshKeyPub2:
  file.blockreplace:
    - name: /root/.ssh/authorized_keys
    - marker_start: "## scm-sshKeyPub start ##"
    - marker_end: "## scm-sshKeyPub end ##"
    - content: |
        {{ pillar["myShadow"]["cdh5"]["scm-keyPub"] }}
    - append_if_not_found: True
    - backup: '.bak'
    - require:
      - file : scm-sshKeyPub1

{% if "cdh5-scmMaster" in pillar["roles"] %}
scmMaster-sshKey:
  file.managed:
    - name: /root/.ssh/id_rsa
    - user: root
    - group: root
    - file_mode: 600
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:cdh5:scm-key
{% endif %}

##启动服务@@

##监控服务@@
