openLdap_pkg:
  pkg:
    - name: nss-pam-ldapd
    - installed
    - require:
      - service: openLdap_pkg_dead

openLdap_pkg_dead:
  service:
    - names:
      - sssd
      - oddjobd
    - dead
    - enable: false

openLdap_installScript:
  cmd.wait:
    - name: /usr/local/cntv/shell/ldapClientInstall.sh
    - user: root
    - watch:
      - file: /usr/local/cntv/shell/ldapClientInstall.sh

/usr/local/cntv/shell/ldapClientInstall.sh:
  file.managed:
    - source: salt://common/openLdap/ldapClientInstall.sh.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /usr/local/cntv/shell