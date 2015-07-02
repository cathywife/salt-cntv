1.logstash配置文件：
 - /etc/sysconfig/elasticsearch 系统服务的配置（java内存，worker数量等）
 - /etc/logstash/logstash.conf 服务配置（日志切分配置）

2.java优化：
 - http://unixboy.iteye.com/blog/174173

3.logstash优化：
 - 总体：
  - 内存限制：LS_JAVA_OPTS="-Xms{{(grains['mem_total']*0.2)|round|int}}m -Djava.io.tmpdir=${LS_HOME}"
  - worker数量：LS_WORKER_THREADS=2
  - 文件打开数量：LS_OPEN_FILES=65535
 - 注意事项：
  - 不要使用官方弃用的插件，以防升级后无法使用
  - 安装第三方插件包（logstash-contrib），才能享用文档里提及的所有插件
  - 切割掉不必要的字段，减少存入ES的数据
  - redis使用list方式获取数据，以提高性能
  - 尽量少使用grok表达式，比如nginx可以直接输出json格式日志
  - ES的output方式使用elasticsearch_http可以大幅提升性能，且可与es节点es版本解耦