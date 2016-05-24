---
layout: post
title: ELK (Elasticsearch Logstash Kibana) Stack
---

## Introduction

The ELK stack consists of Elasticsearch, Logstash, and Kibana.

This article will walk you through the install and setup a working ELK stack.

Elasticsearch Features at

* Real-time data and real-time analytics
* Scalable, high-availability, multi-tenant
* Full text search
* Document orientation

<!--more-->

## Install

```
Logstash1  Logstash2   Logstash3
--------   ---------   ---------
    \           |           /
     \          |          /
      \         |         /
       \        |        /
       ------------------
       | balance node   |
       ------------------
               /\
              /  \
             /    \
    ------------  --------------
    | data node|  | data node2 |
    ------------  --------------
```

### Elastic Search

#### Configure

`elasticsearch-2.3.1/config/elasticsearch.yml`

**Data Nodes**

```yaml
cluster.name: es-babel
node.name: es-babel06

path.data: /data/es

# bind addr
network.host: babel06.oxnz.github.io
# port for HTTP
http.port: 8200

# discovery
discovery.zen.ping.unicast.hosts: ['babel05.oxnz.github.io']

# index
index.number_of_shards: 1
index.number_of_replicas: 1
```

**Load Balance Node**

```yaml
# resign both master and data make the node became a load balance role
node.master: false
node.data: false
```

#### Exec

```shell
export ES_HEAP_SIZE=10g
./elasticsearch-2.3.1/bin/elasticsearch --daemonize
```

#### Verify Cluster Status

```shell
curl $(hostname):8200/_cat/health
```

### Kibana

#### Install

```shell
tar zxf kibana-4.5.0-linux-x64.tar.gz
```

#### Configure

`kibana-4.5.0-linux-x64/config/kibana.yml`

```yaml
# bind addr
server.host: 'localhost'
# Elasticsearch instance URL
elasticsearch.url: 'http://balance.oxnz.github.io:9200'
```

#### Nginx Reverse Proxy

```nginx
server {
	listen: 8000;
	server_name: kibana.oxnz.github.io;
	location / {
		proxy_pass http://localhost:5601;
	}
```

## Performances

### CPU

Most Elasticsearch deployments tend to be right light on CPU requirements. So the processor setup matters less than other resources. Modern processor with 2~8 cores are recommonded.

More cores performs bettern that faster CPUs.

### Memory

Sorting and aggregations can both be memory hungry. Even when the heap is comparatively small, extra memory can be given to the OS filesystem cache. Bacause many data structures used by Lucene are disk-based formats, ELasticsearch leverages the OS cache to great effect.

64 GB matchines are recommended, 32 GB and 16 GB are common. Less than 8 GB would result in many many small machines, and greater than 64 GB would hurt the performance.

### Storage

Disks are important for all clusters, especially for indexing-heavy clusters. And can easily become the bottleneck of the cluster.

#### SSD

Make sure I/O scheduler is configured correctly. Cause it is the scheduler who decides when the data is accually sent to the disk. The default is mostly called `cfq` (Completely Faire Queuing).

This scheduler allocates time slices to each process, and then optimizes the delivery of these various queues to the disk. It is optimized for spining media, the nature of rotating platters means it is more efficient to write data to disk based on physical layout.

This is inefficient for SSD, however, since there are no spinning platters involved. Instead, deadline or noop should be used instead. The deadline scheduler optimizes based on how long writes have been pending, while noop is just a simple FIFO queue.

This simple change can have dramatic impacts. We’ve seen a 500-fold improvement to write throughput just by using the correct scheduler.

#### RAID

Using RAID 0 is an effective way to increse disk speed, for both spining disks and SSD. There is no need to use mirroring or parity variants of RAID, since high availability is built into Elasticsearch via replicas.

#### NAS (Network-Attached Storage)

Avoid NAS if possible. NAS is relativly slow and a single point of failure.

### Network

A fast and reliable network is obviously important to performance in a distributed system. Low latency helps ensure that nodes can communicate easily, while high bandwidth helps shard movement and recovery. 1 GbE, 10 GbE is sufficient for most clusters.

Avoid clusters that span multiple data centers.

Elasticsearch clusters assume that all nodes are equal. Larger latencies tend to exacerbate problems in distributed systems and make debugging and resolution more difficult.

### General Considerations

Prefer medium-to-large machines other than too many small virtual boxes.

Avoid the truly enormous machines. They often lead to imbalanced resource usage(all memory but none of the CPU) and can add logistical complexity if you have to run multiple nodes per machine.

## Memory Management

Elasticsearch is configured with 1 GB heap memory by default. And this is apparently too small for production.

```shell
# set environment variable
export ES_HEAP_SIZE=10g
```

### Considerations

* Give (less than) Half Memory to Lucene
* No more than 32 GB ([compressed oops](https://wikis.oracle.com/display/HotSpotInternals/CompressedOops))
* How Far Under 32 GB Depends On JVM and OS

```shell
$ JAVA_HOME=`/usr/libexec/java_home -v 1.7` java -Xmx32600m -XX:+PrintFlagsFinal 2> /dev/null | grep UseCompressedOops
  bool UseCompressedOops   := true
$ JAVA_HOME=`/usr/libexec/java_home -v 1.7` java -Xmx32766m -XX:+PrintFlagsFinal 2> /dev/null | grep UseCompressedOops
  bool UseCompressedOops   = false
```

`elasticsearch-2.3.1/logs/elasticsearch-babel.log`

```log
[2016-05-18 15:31:57,088][INFO ][env                      ] [elasticsearch-babel06] heap size [9.8gb], compressed ordinary object pointers [true]
```
* Swapping Is the Death of Performance

```conf
# 0 may invoke the OOM-killer
vm.swappiness = 1
```

**Note**

Ensure that the min(Xms) and max(Xmx) sizes are the same to prevent the heap from resizing at runtime, a very costly process.

## Diagnose

0. service unavailable

```shell
$ curl http://tc-ite-babel01.tc.baidu.com:9200/_cat/count?pretty=true
```

```json
{
  "error" : {
    "root_cause" : [ ],
    "type" : "search_phase_execution_exception",
    "reason" : "all shards failed",
    "phase" : "query",
    "grouped" : true,
    "failed_shards" : [ ]
  },
  "status" : 503
}
```

## Production Deployment

* Logistical considerations, such as hardware recommendations and deployment strategies
* Configuration changes to suit a production environment
* Post-deployment considerations, such as security, maximizing indexing performance and backups

## References

* [Heap: Sizing and Swapping](https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html)
* [elasticsearch indexing performance cheatsheet](https://blog.codecentric.de/en/2014/05/elasticsearch-indexing-performance-cheatsheet/)
