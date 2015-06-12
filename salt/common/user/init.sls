#种key root@controlCenter
{% if "base" in pillar["roles"] %}
/root/.ssh/authorized_keys:
  file.managed:
    - user: root
    - group: root
    - file_mode: 600
    - dir_mode: 700
    - makedirs: True
    - contents_pillar: myShadow:system:root:sshKey_pub
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
