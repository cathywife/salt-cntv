salt-cntv
=========

## Architecture

###本环境是基于角色组件做配置管理的，与salt nodegroup的表示方法区别如下：


项目 | 服务器  | 角色 | 组件 | 变量 | 服务器组 | 服务器列表文件
--- | ------- | --- |----- |---- |-------- | ------------
本环境|ID|roles|states|pillar或project.*组件|无|/data/saltServersList.csv
salt官方|salt-key|无|states|pillar或grains|nodegroup|无

**不使用nodegroup原因是难维护，无法实现多对多逻辑**

举例：
```
├─10.0.0.1─┬─base─┬─common.user(根据"centralControl"角色自动为其分配公钥和私钥,而不是其他机器只分配公钥-by pillar)
│          │      ├─common.monit
│          │      ├─...
│          │      └─common.rsyslog(根据"syslogCenter"角色自动为其分配server端配置,而不是其他机器的client端配置-by pillar)
│          ├─centralControl─┬─saltMaster(根据角色安装saltMaster组件,而不是在roles中指定安装-by top.sls)
│          │                ├─monitServer(根据角色安装monitServer组件,而不是在roles中指定-by top.sls)
│          └─syslogCenter──beaver(根据角色安装beaver组件,而不是在roles中指定-by top.sls)
├─10.0.0.2 ...
...
```

###使用本环境必读：
- states文件是组件，而不是角色
- 角色设置中不要使用软件名称，例如：使用app1-webServer而不是app1-apache
- 在top.sls文件中为角色分配组件，例如：
```
base:
  'I@roles:app1-webServer':
    - match: compound
    - apache
    - beaver-apache
```
- states是部署方法文件，而不是配置管理文件，不要尝试把软件配置放置在states文件中，那会使文件更难读懂
- pillar是配置存储文件，请尝试用pillar管理组件的配置，用jinja模板管理pillar会使配置管理便得非常灵活


###执行流程：
```
/data/saltServersList.csv server parameters     #human readable managed servers data
    ^^^
    |||
/shell/convertServerList.sh                     #conver above table to salt pillar
    |||
    VVV
salt pillar                                     #varible data based on serverIP
    ^^^
    |||
salt states file                                #pre defined states files
    ^^^
    |||
halite or salt master cli                       #tiggered tasks by human
    |||
    VVV
salt minion                                     #make changes and hold the right status on each server!
```

###配置使用指南：

1. 客户端部署minion
2. 分析服务器角色、基本数据输入：/data/saltServersList.csv (可以添加新列)
3. salt/top.sls 为新角色分配组件
4. 组件配置
5. 执行 shell/highstate.sh test 测试效果
6. 执行 shell/highstate.sh 发布任务

客户端部署脚本：
```
#安装salt-minion#
adminIP=`/sbin/ifconfig |sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p' |grep -P "^192|^10" |sort |head -n 1`
sed -i "/saltMaster$\|centralControl$/d" /etc/hosts
echo -e "x.x.x.x\tsaltMaster\nx.x.x.x\tcentralControl" >> /etc/hosts

[ -f /etc/salt/minion ] && { yum remove -y zeromq salt-minion; rm -rf /etc/salt/pki; } 

rm -f /etc/yum.repos.d/*
curl http://centralControl/webServer/cntvInternal.repo > /etc/yum.repos.d/cntvInternal.repo

yum groupinstall -y base
yum install -y --enablerepo=cntvInternal zeromq zeromq-devel python-zmq python26-zmq python26-distribute salt-minion
\cp /etc/salt/minion /etc/salt/minion.bak
echo "master: saltMaster
backup_mode: minion
log_file: /var/log/salt/minion
log_level: info" > /etc/salt/minion
echo "$adminIP" > /etc/salt/minion_id
service salt-minion restart
chkconfig salt-minion on
#完成#
```

###使用fabric批量部署客户端：
```
yum install python-pip gmp-devel gcc python-devel
pip install fabric

salt/project/fabric/fabfile.py
salt/project/fabric/installSalt.sh

fab go
```

#其他注意事项（可以不看）：

## jinja2
中文文档：
http://docs.jinkan.org/docs/jinja2/templates.html

## pillar使用方法：
使用pillar规划服务器角色，在pillar文件中指定服务器角色，为states tree匹配提供基础。

	salt "*" pillar.data
```
x.x.x.x:
    ----------
    CentOS-6:
        - none
    Roles:
        - common-base

x.x.x.x-logstash:
    ----------
    CentOS-5:
        - none
    Roles:
        - rsyslog
        - common-base
        - adminServer-centralControl
        - adminServer-svnServer-cluster63.228
        - adminServer-jenkinsServer
        - common-beaver-shipper
```

**master上更新后一定要同步：**

```
salt "*" saltutil.refresh_pillar
```

```
#下面两条命令分别显示master和minion存储的pillar
salt "*" pillar.items
salt "*" pillar.raw
```

匹配方法

	salt -v -I "Roles:common-base" test.ping


1、匹配方式：判断角色尽量使用startwith,find等匹配，sh脚本靠-拆分出的角色纯粹为了简化，尽量不要使用，这是遗留问题。
