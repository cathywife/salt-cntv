####单机单实例配置开始@@

##软件包安装@@
postfix_pkg:
  pkg.latest:
    - names:
      - postfix
      - libgsasl

##创建并设置目录权限@@
#

##执行命令@@
postfix_postmap:
  cmd.run:
    - name: /usr/sbin/postmap /etc/postfix/sasl-passwords
    - user: root
    - unless: '[ -f /etc/postfix/sasl-passwords.db ]'
    - require:
      - pkg: postfix_pkg
      - file: /etc/postfix/sasl-passwords

postfix_sasldb:
  cmd.run:
    - name: "echo monit| saslpasswd2 -c -p -u cntv.priv monit; chown postfix.postfix /etc/sasldb2"
    - user: root
    - unless: '[ -f /etc/sasldb2 ]'
    - require:
      - pkg: postfix_pkg

##修改配置@@
/etc/postfix/main.cf:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: postfix:mainConf
    - require:
      - pkg: postfix_pkg

/etc/postfix/sasl-passwords:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: myShadow:postfix:sasl-passwords
    - require:
      - pkg: postfix_pkg

/etc/sasl2/smtpd.conf:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - contents_pillar: postfix:smtpdConf
    - require:
      - pkg: postfix_pkg

##启动服务@@
service_postfix:
  service.running:
    - name: postfix
    - enable: True
    - watch:
      - pkg: postfix_pkg
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/sasl-passwords
