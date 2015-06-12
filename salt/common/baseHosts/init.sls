base_hosts:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "## base start ##"
    - marker_end: "## base end ##"
    - content: |
        {{ pillar["hosts"]["baseHosts"] }}
    - append_if_not_found: True
    - backup: '.bak'
    - order: 1