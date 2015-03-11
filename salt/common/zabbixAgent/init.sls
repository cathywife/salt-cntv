zabbixAgent_tgz:
  cmd.wait:
    - name: "tar zxf /usr/local/zabbix.tgz -C /usr/local"
    - user: root
    - stateful: True
    - watch: 
      - file: /usr/local/zabbix.tgz
    - oreder: 100

zabbixAgent_ldconfig:
  cmd.wait:
    - name: "ldconfig -f /etc/ld.so.conf.d/zabbixAgent.conf"
    - user: root
    - stateful: True
    - watch: 
      - file: /etc/ld.so.conf.d/zabbixAgent.conf
    - oreder: 110

zabbixAgent_service:
  cmd.wait:
    - name: "chkconfig zabbix_agentd on; /etc/init.d/zabbix_agentd restart;"
    - user: root
    - watch:
      - file: /etc/init.d/zabbix_agentd
    - oreder: 120

#文件
#链接库
/etc/ld.so.conf.d/zabbixAgent.conf:
  file.managed:
    - source: salt://common/zabbixAgent/ld.so.conf.d/zabbixAgent.conf
    - user: root
    - group: root
    - file_mode: 755

#服务脚本
/etc/init.d/zabbix_agentd:
  file.managed:
    - source: salt://common/zabbixAgent/init.d/zabbix_agentd
    - user: root
    - group: root
    - mode: 0755

#配置文件
/usr/local/zabbix/etc/zabbix_agentd.conf:
  file.managed:
    - source: salt://common/zabbixAgent/etc/zabbix_agentd.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
    - defaults:
        hostname: {{ salt['cmd.run']('/usr/local/cntv/sys_getHostName.sh') }}
    - require:
      - file:  /usr/local/cntv

#软件静态文件
/usr/local/zabbix.tgz:
  file.managed:
    - source: salt://common/zabbixAgent/files/zabbix.tgz
    - user: root
    - group: root
    - mode: 0755
    - makedirs: True
