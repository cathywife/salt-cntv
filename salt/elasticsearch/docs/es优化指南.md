1.es配置文件：
 - /etc/sysconfig/elasticsearch 系统服务的配置（java内存等）
 - /etc/elasticsearch/elasticsearch.yml 服务配置（群集，恢复等）

2.java优化：
 - http://unixboy.iteye.com/blog/174173

3.es优化：
 - 总体：
  - heap内存 设置为总内存的50%，并且不要超过30.5G
  - 分片数量>=节点数量*2 （提高分片数量均衡负载，分片数量一定不能小于节点数量）
  - 副本数量>=2 （副本数量越大查询性能越好，受存储空间限制）
  - /etc/sysconfig/elasticsearch 中 ES_HEAP_SIZE 设置为"物理内存-2048m"提高性能
 - 索引性能：
  - refresh_interval 提高索引刷新时间可有效增加索引吞吐量 （参考：1s to 5s, index rate:25%up）
  - indices.memory.index_buffer_size: 50% 通过buffer增加索引性能
  - index.index_concurrency: 2 每个shard可同时索引的线程数，与每节点的shard数量相关
  - index.merge.scheduler.max_thread_count: 1 merge的进程数限制，使用SSD时适量增加
 - 搜索性能：
  - indices.fielddata.cache.size: 25% 通过cache增加搜索性能
  - indices.store.throttle.max_bytes_per_sec : 100mb （最大存储速率，平衡存储和搜索性能indices.store.throttle.type : none 最大存储速度）
 - 计划任务：
  - 定时优化索引：curl -XPOST "http://es节点:9200/索引名称/_optimize"
  - 删除不需要的索引：curl -XDELETE "http://es节点:9200/索引名称"
 - 安全：
  - 关闭自定义脚本 action.disable_delete_all_indices: true
  - 关闭删除所有索引 script.groovy.sandbox.enabled: false


常见错误：
1. EsRejectedExecutionException[rejected execution (queue capacity 50)
```
threadpool.bulk.type: fixed
threadpool.bulk.size: 8                 # availableProcessors
threadpool.bulk.queue_size: 5000
```
2. test


技巧：
1. 在线更改配置：
```
curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'

curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "threadpool.bulk.type" : "fixed",
        "threadpool.bulk.size" : 8,
        "threadpool.bulk.queue_size" : 5000
    }
}'
```
2. 