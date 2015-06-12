sudoers_append:

  file.blockreplace:
    - name: /etc/sudoers
{%- if "baseA" in pillar['roles'] %}
    - marker_start: "## Allows people in group wheel to run all commands"
{% else %}
    - marker_start: "## Same thing without a password"
{%- endif %}
    - marker_end: "## Allows members of the users group to mount and unmount the "
    - content: |
{%- if "baseA" in pillar['roles'] %}
        %wheel             ALL=(ALL)       ALL
        %ops               ALL=(ALL)       ALL
        %appops            ALL=(ALL)       ALL
        %operations        ALL=(ALL)       ALL
        %security          ALL=(ALL)       ALL
        %outsourcingOps    ALL=(ALL)       ALL
        {%- if "weibo" in pillar["roles"] %}
        %iops              ALL=(ALL)       ALL
        {%- endif %}
        {%- if "ldapAllowGroups" in pillar %}
        {%- if "dev" in pillar["ldapAllowGroups"] %}
        %idev              ALL=DENYCOMMAND, DENYCOMMAND2, INDIVIDUALS, NETWORKING, SOFTWARE, SERVICES, STORAGE, DELEGATING, PROCESSES, LOCATE, DRIVERS
        %outsourcing       ALL=DENYCOMMAND, DENYCOMMAND2, INDIVIDUALS, NETWORKING, SOFTWARE, SERVICES, STORAGE, DELEGATING, PROCESSES, LOCATE, DRIVERS
        {%- endif %}
        {%- endif %}
        ## Same thing without a password
{%- endif %}
        #%wheel             ALL=(ALL)       NOPASSWD: ALL
        autoOps            ALL=(ALL)       NOPASSWD: ALL
        
        Defaults           requiretty
        Defaults:autoOps   !requiretty
{%- if "tms-rsync" in pillar["roles"] %}
        Defaults:tms       !requiretty
{%- elif "tms-ftp" in pillar["roles"] %}
        Defaults:tms       !requiretty
{%- endif %}
    - append_if_not_found: True
    - backup: '.bak'

#sudoers_comment:
#  file.comment:
#    - name: /etc/sudoers
#    - regex: ^Defaults    requiretty$