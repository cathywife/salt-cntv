####单机单实例配置@@

##pillar名称@@
elasticsearch:
{% if grains['roles'] is defined %}

##定制pillar（单机单实例应使用相同变量名称）@@
{% if 'logstash-esNode' in grains['roles'] %}
  pkg: "salt://elasticsearch/files/elasticsearch-1.4.4.noarch.rpm"
  plugins: "salt://elasticsearch/files/plugins.tgz"
  dataDir: "/syslog/ESdata"
  minMem: "ES_MIN_MEM={{ (grains['mem_total'] * 0.9 )|int }}m"
  maxMem: "ES_MAX_MEM={{ (grains['mem_total'] * 0.9 )|int }}m"
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
    
    cluster.routing.allocation.node_initial_primaries_recoveries: 4
    cluster.routing.allocation.node_concurrent_recoveries: 4
    indices.recovery.max_bytes_per_sec: 400mb
    indices.recovery.concurrent_streams: 5
    indices.memory.index_buffer_size: 50%
    
    discovery.zen.ping.timeout: 20s
    discovery.zen.ping.unicast.hosts: ["logstash-esNode-1","logstash-esNode-2","logstash-esNode-3", "logstash-esNode-4", "logstash-esNode-5", "logstash-esNode-6","logstash-esSearchNode-1", "logstash-esSearchNode-2"]
    
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
{% elif 'logstash-esSearchNode' in grains['roles'] %}
  pkg: "salt://elasticsearch/files/elasticsearch-1.4.4.noarch.rpm"
  plugins: "salt://elasticsearch/files/plugins.tgz"
  dataDir: "/syslog/ESdata"
  minMem: "ES_MIN_MEM={{ (grains['mem_total'] * 0.7)|int }}m"
  maxMem: "ES_MAX_MEM={{ (grains['mem_total'] * 0.7)|int }}m"
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

    discovery.zen.ping.unicast.hosts: ["logstash-esNode-1","logstash-esNode-2","logstash-esNode-3", "logstash-esNode-4", "logstash-esNode-5", "logstash-esNode-6","logstash-esSearchNode-1", "logstash-esSearchNode-2"]
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
    bootstrap.mlockall: true
    gateway.recover_after_nodes: 2
    gateway.recover_after_time: 5m
    gateway.expected_nodes: 2
    cluster.routing.allocation.node_initial_primaries_recoveries: 4
    cluster.routing.allocation.node_concurrent_recoveries: 4
    indices.recovery.max_bytes_per_sec: 400mb
    indices.recovery.concurrent_streams: 5
    discovery.zen.ping.unicast.hosts: ["logstash-esMonitorNode-1","logstash-esMonitorNode-2","logstash-esMonitorNode-3","logstash-esMonitorNode-4"]
    index.cache.field.max_size: 50000
    index.cache.field.expire: 10m
    index.cache.field.type: soft
    marvel.agent.enabled: false
{% endif %}

{% endif %}
