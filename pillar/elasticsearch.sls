####单机单实例配置@@
elasticsearch:
{% if grains['roles'] is defined %}
{% if grains['roles'] is iterable %}

##定制pillar（单机单实例应使用相同变量名称）@@
{% if 'logstash-esNode' in grains['roles'] %}
  pkg: "salt://elasticsearch/files/elasticsearch-1.4.4.noarch.rpm"
  plugins: "salt://elasticsearch/files/plugins.tgz"
  dataDir: "/syslog/ESdata"
  minMem: "ES_MIN_MEM={{ (grains['mem_total'] - 2048 )|int }}m"
  maxMem: "ES_MAX_MEM={{ (grains['mem_total'] - 2048 )|int }}m"
  mainConf: |
    cluster.name: elasticsearch-test-cluster
    node.name: node-{{ grains['id'] }}
    node.master: false
    
    index.number_of_shards: 12
    index.number_of_replicas: 1
    path.data: /syslog/ESdata
    bootstrap.mlockall: true
    
    gateway.recover_after_nodes: 1
    gateway.recover_after_time: 5m
    gateway.expected_nodes: 100
    
    cluster.routing.allocation.node_initial_primaries_recoveries: 18
    cluster.routing.allocation.node_concurrent_recoveries: 4
    indices.recovery.concurrent_streams: 5
    indices.recovery.max_bytes_per_sec: 400mb

    cluster.routing.allocation.cluster_concurrent_rebalance: 2
    cluster.routing.allocation.disk.threshold_enabled: true
    cluster.routing.allocation.disk.watermark.low: 76%
    cluster.routing.allocation.disk.watermark.high: 79%
    
    indices.memory.index_buffer_size: 50%
    indices.fielddata.cache.size: 30%
    
    discovery.zen.ping.timeout: 30s
    discovery.zen.minimum_master_nodes: 2
    discovery.zen.ping.multicast.enabled: false
    discovery.zen.ping.unicast.hosts: ["logstash-esNode-1","logstash-esNode-2","logstash-esNode-3", "logstash-esNode-4", "logstash-esNode-5", "logstash-esNode-6","logstash-esNode-7", "logstash-esNode-8", "logstash-indexer-1", "logstash-indexer-2"]
    
    index.cache.field.max_size: 50000
    index.cache.field.expire: 10m
    index.cache.field.type: soft
    
    marvel.agent.exporter.es.hosts: ["logstash-esMonitorNode-1:9200"]
    index.translog.flush_threshold_ops: 50000
    
    # Search thread pool
    threadpool.search.type: fixed
    threadpool.search.size: 20
    threadpool.search.queue_size: 100
    
    # Index thread pool
    threadpool.index.type: fixed
    threadpool.index.size: 60
    threadpool.index.queue_size: 200
    
    action.disable_delete_all_indices: true
    script.groovy.sandbox.enabled: false
{% elif 'logstash-esSearchNode' in grains['roles'] %}
  pkg: "salt://elasticsearch/files/elasticsearch-1.4.4.noarch.rpm"
  plugins: "salt://elasticsearch/files/plugins.tgz"
  dataDir: "/syslog/ESdata"
  minMem: "ES_MIN_MEM={{ (grains['mem_total'] * 0.2)|int }}m"
  maxMem: "ES_MAX_MEM={{ (grains['mem_total'] * 0.2)|int }}m"
  mainConf: |
    cluster.name: elasticsearch-test-cluster
    node.name: "node-{{ grains['id'] }}-search"
    node.data: false
    
    index.number_of_shards: 12
    index.number_of_replicas: 1
    path.data: /syslog/ESdata
    bootstrap.mlockall: true
    
    gateway.recover_after_nodes: 1
    gateway.recover_after_time: 5m
    gateway.expected_nodes: 100
    
    cluster.routing.allocation.node_initial_primaries_recoveries: 4
    cluster.routing.allocation.node_concurrent_recoveries: 4
    
    indices.recovery.max_bytes_per_sec: 400mb
    indices.recovery.concurrent_streams: 5
    indices.memory.index_buffer_size: 50%
    indices.fielddata.cache.size: 30%
    index.cache.field.max_size: 50000
    index.cache.field.expire: 10m
    index.cache.field.type: soft
    
    discovery.zen.ping.unicast.hosts: ["logstash-esNode-1","logstash-esNode-2","logstash-esNode-3", "logstash-esNode-4", "logstash-esNode-5", "logstash-esNode-6","logstash-esNode-7", "logstash-esNode-8", "logstash-indexer-1", "logstash-indexer-2"]
    marvel.agent.exporter.es.hosts: ["logstash-esMonitorNode-1:9200"]
    
    # Search thread pool
    threadpool.search.type: fixed
    threadpool.search.size: 20
    threadpool.search.queue_size: 100
    
    # Index thread pool
    threadpool.index.type: fixed
    threadpool.index.size: 60
    threadpool.index.queue_size: 200
    
    # kibana
    http.cors.enabled: true
    http.cors.allow-origin: http://10.64.0.1
    
    script.groovy.sandbox.enabled: false
{% elif 'logstash-esMonitorNode' in grains['roles'] %}
  pkg: "salt://elasticsearch/files/elasticsearch-1.4.4.noarch.rpm"
  plugins: "salt://elasticsearch/files/plugins.tgz"
  dataDir: "/syslog/ESdata"
  minMem: "ES_MIN_MEM={{ (grains['mem_total'] * 0.7)|int }}m"
  maxMem: "ES_MAX_MEM={{ (grains['mem_total'] * 0.7)|int }}m"
  mainConf: |
    cluster.name: elasticsearch-marvel
    node.name: "node-{{ grains['id'] }}-marvel"
    index.number_of_shards: 1
    index.number_of_replicas: 1
    path.data: /syslog/ESdata
    #bootstrap.mlockall: true
    
    gateway.expected_nodes: 2
    gateway.recover_after_nodes: 1
    gateway.recover_after_time: 20m
    
    cluster.routing.allocation.node_initial_primaries_recoveries: 2
    cluster.routing.allocation.node_concurrent_recoveries: 2
    indices.recovery.max_bytes_per_sec: 400mb
    indices.recovery.concurrent_streams: 5
    discovery.zen.ping.unicast.hosts: ["logstash-esMonitorNode-1","logstash-esMonitorNode-2"]
    index.cache.field.max_size: 50000
    index.cache.field.expire: 10m
    index.cache.field.type: soft
    marvel.agent.enabled: false
    
    script.groovy.sandbox.enabled: false
{% endif %}

##判断minion是否已经初始化@@
{% endif %}
{% endif %}