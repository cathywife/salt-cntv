#该文件作用：目前使用*匹配所有pillar

#"-" 表示列表,键值对不要使用"-" 例如:
#A:
#  key1: value1
#  sublist:
#    - value1
#    - value2
#用法： pillar["A"]["key1"]
#用法： for value in pillar["A"]["sublist"]

base:
  '*':
####generated:####
    - desc
    - roles
    - ldapAllowGroups
    - hostname
    - maintainers
    - location
####predefined:####
    - beaver
    - collectd
    - crontab
    - elasticsearch
    - ldapAllowGroupsDict
    - logstash
    - myShadow
    - redis
    - svnServer
