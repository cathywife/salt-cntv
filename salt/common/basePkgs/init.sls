common_pkgs:
  pkg.latest:
    - names:
{% if grains['os_family'] == "RedHat" %}
      - rsync
      - wget
      - psmisc
      - ntp
      - crontabs
      #- gcc
      #- make
{% endif %}
    - require:
      - file: /etc/yum.repos.d/cntvInternal.repo