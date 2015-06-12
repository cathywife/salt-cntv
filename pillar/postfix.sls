####单机单实例配置@@
postfix:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

  {% if 'smtpRelayServer' in grains['roles'] %}
  mainConf: |
    queue_directory = /var/spool/postfix
    command_directory = /usr/sbin
    daemon_directory = /usr/libexec/postfix
    mail_owner = postfix
    inet_interfaces = all
    mydestination = $myhostname, localhost.$mydomain, localhost
    unknown_local_recipient_reject_code = 550
    alias_maps = hash:/etc/aliases
    alias_database = hash:/etc/aliases
    
    debug_peer_level = 2
    debugger_command =
             PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
             xxgdb $daemon_directory/$process_name $process_id & sleep 5
    sendmail_path = /usr/sbin/sendmail.postfix
    newaliases_path = /usr/bin/newaliases.postfix
    mailq_path = /usr/bin/mailq.postfix
    setgid_group = postdrop
    html_directory = no
    manpage_directory = /usr/share/man
    sample_directory = /usr/share/doc/postfix-2.3.3/samples
    readme_directory = /usr/share/doc/postfix-2.3.3/README_FILES
    
    mynetworks = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
    mynetworks_style = subnet
    relayhost = [smtp.163.com]
    smtp_sasl_auth_enable=yes
    smtp_sasl_password_maps=hash:/etc/postfix/sasl-passwords
    smtp_sasl_security_options =

    smtpd_sasl_local_domain = cntv.priv
    smtpd_sasl_auth_enable = yes
    smtpd_sasl_security_options = noanonymous
    smtpd_client_restrictions = permit_sasl_authenticated,reject
    broken_sasl_auth_clients = yes
  smtpdConf: |
    pwcheck_method: auxprop
    auxprop_plugin: sasldb
    mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 NTLM
  {% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}