#种key root@controlCenter
{% if "baseA" in pillar["roles"] %}
root-sshKeyPubPath:
  file.directory:
    - name: /root/.ssh
    - user: root
    - group: root
    - dir_mode: 700

root-sshKeyPubCmd:
  cmd.run:
    - name: "touch /root/.ssh/authorized_keys; chmod 600 /root/.ssh/authorized_keys"
    - unless: "[ -f /root/.ssh/authorized_keys ]"
    - user: root
    - require:
      - file: root-sshKeyPubPath

root-sshKeyPubFile:
  file.blockreplace:
    - name: /root/.ssh/authorized_keys
    - marker_start: "## root-sshKeyPub start ##"
    - marker_end: "## root-sshKeyPub end ##"
    - content: |
        {{ pillar["myShadow"]["system"]["root"]["sshKey_pub"] }}
    - append_if_not_found: True
    - backup: '.bak'
    - require:
      - file: root-sshKeyPubPath
      - cmd: root-sshKeyPubCmd
{% endif %}

#中央服务器复制root autoOps的sshkey
{% if "centralControl" in pillar["roles"] %}
/home/autoOps/.ssh/id_rsa:
  file.managed:
    - user: autoOps
    - group: autoOps
    - file_mode: 600
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:autoOps:sshKey_priv
    - require:
      - user: autoOps

/home/autoOps/.ssh/id_rsa.pub:
  file.managed:
    - user: autoOps
    - group: autoOps
    - file_mode: 0644
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:autoOps:sshKey_pub
    - require:
      - user: autoOps

/root/.ssh/id_rsa:
  file.managed:
    - user: root
    - group: root
    - file_mode: 600
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:root:sshKey_priv

/root/.ssh/id_rsa.pub:
  file.managed:
    - user: root
    - group: root
    - file_mode: 0644
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:root:sshKey_pub
{% endif %}
