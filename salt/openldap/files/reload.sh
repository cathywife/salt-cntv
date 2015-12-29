rm -rf /etc/openldap/slapd.d/*
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
chmod 755 /etc/openldap
chown -R ldap:ldap /etc/openldap
service slapd restart

