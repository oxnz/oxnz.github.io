---
layout: post
title: ELK (Elasticsearch Logstash Kibana) Stack
---

## Introduction

The ELK stack consists of Elasticsearch, Logstash, and Kibana.

This article will walk you through the install and setup a working ELK stack.
As well as some basic performance tuning.

Elasticsearch Features at

* Real-time data and real-time analytics
* Scalable, high-availability, multi-tenant
* Full text search
* Document orientation

<!--more-->

## Table of Contents

* TOC
{:toc}

## Install

```
------------- ------------- -------------
| Logstash1 | | Logstash2 | | Logstash3 |
------------- ------------- -------------
         \         |        /
          ------------------               ----------      ---------
          |  balance node  | -----...----> | Kibana | ---> | Nginx |
          ------------------               ----------      ---------
           /             \
    ------------  --------------
    | data node|  | data node2 |
    ------------  --------------
```

### Download

```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.2.tar.gz
wget https://download.elastic.co/elasticsearch/release/org/\
elasticsearch/distribution/tar/elasticsearch/2.4.1/elasticsearch-2.4.1.tar.gz
wget https://download.elastic.co/logstash/logstash/logstash-2.4.0.tar.gz
wget https://download.elastic.co/kibana/kibana/kibana-4.6.1-linux-x86_64.tar.gz
wget http://nginx.org/download/nginx-1.8.1.tar.gz
```

### Elasticsearch

#### Configure

`elasticsearch-2.3.1/config/elasticsearch.yml`

**Data Node**

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
index.number_of_shards: 2 (default is 5)
index.number_of_replicas: 1 (default is 1)
```

**Load Balance Node**

```yaml
# resign both master and data make the node became a load balance role
node.master: false
node.data: false
```

#### Exec

```shell
ES_HEAP_SIZE=10g ./elasticsearch-2.3.1/bin/elasticsearch --daemonize
```

#### Operations

```shell
# view indexes
curl 'localhost:9200/_cat/aliases?v'
curl 'localhost:9200/_cat/allocation?v'
curl 'localhost:9200/_cat/count'
curl 'localhost:9200/_cat/fielddata?v'
curl "$(hostname):9200/_cat/indices/logstash-*?v"
# verify cluster status
curl "$(hostname):8200/_cat/health?v"
curl 'localhost:9200/_cat/master?v'
curl 'localhost:9200/_cat/nodeattrs'
curl '0.0.0.0:9200/_cat/nodes?v'
curl 'localhost:9200/_cat/pending_tasks?v'
curl 'localhost:9200/_cat/plugins?v'
curl -XGET 'localhost:9200/_cat/recovery?v'
curl -XDELETE 'localhost:9200/logstash-*'
curl 'localhost:9200/_cat/repositories?v'
curl 'localhost:9200/_cat/thread_pool?v'
curl 'localhost:9200/_cat/shards'
curl 'http://localhost:9200/_cat/segments?v'
curl 'localhost:9200/_cat/snapshots/repo1?v'
GET '_cluster/health?level=indices'
GET '_cluster/health?level=shards'
GET '_cluster/health?wait_for_status=green'
```

#### Status

* green (All primary and replica shards are allocated. The cluster is 100% operational.)
* yellow (All primary shards are allocated, but **at least one replica is missing**)
    * No data is missing, so search results will still be complete.
    * However, your high availability is compromised to some degree.
    * If more shards disappear, the cluster might lose data. (Think of yellow as a warning that should prompt investigation.)
* red (**At least one primary shard (and all of its replicas) is missing**.)
    * The cluster is missing data:
        * searches will return partial results
        * and indexing into that shard will return an exception.

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

Most Elasticsearch deployments tend to be right **light on CPU requirements**. So the processor setup matters less than other resources. Modern processor with 2~8 cores are recommonded.

**More cores performs bettern that faster CPUs.**

### Memory

**Sorting and aggregations can both be memory hungry.** Even when the heap is comparatively small, extra memory can be given to the OS filesystem cache. Bacause many data structures used by Lucene are disk-based formats, ELasticsearch leverages the OS cache to great effect.

64 GB matchines are recommended, 32 GB and 16 GB are common. Less than 8 GB would result in many many small machines, and greater than 64 GB would hurt the performance.

### Storage

**Disks are important for all clusters, especially for indexing-heavy clusters**. And can easily become the bottleneck of the cluster.

#### SSD

Make sure I/O scheduler is configured correctly. Cause it is the scheduler who decides when the data is accually sent to the disk.

The default is mostly called `cfq` (Completely Faire Queuing).
This scheduler allocates time slices to each process, and then optimizes the delivery of these various queues to the disk. It is optimized for spining media, the nature of rotating platters means it is more efficient to write data to disk based on physical layout.

This is inefficient for SSD, however, since there are no spinning platters involved. Instead, `deadline` or `noop` should be used instead. The `deadline` scheduler optimizes based on *how long writes have been pending*, while `noop` is just *a simple FIFO queue*.

>
This simple change can have dramatic impacts. We’ve seen a 500-fold improvement to write throughput just by using the correct scheduler.

**Detect Harddisk Type**

Linux automatically detects SSD, and since kernel version 2.6.29, you may verify sda with:

```shell
cat /sys/block/sda/queue/rotational
```

You should get 1 for hard disks and 0 for a SSD.

**Ramdisk**

```shell
mount -t tmpfs -o size=512m tmpfs /mnt/ramdisk
```

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

### nofile

```
ulimit -Hn 200000
ulimit -Sn 200000
```

**/etc/security/limits.conf**

```
user soft nofile 20000
user hard nofile 24000
# wildcard does not affect the superuser
root soft nofile 20000
root hard nofile 24000
```

**/etc/pam.d/common-session**

```
session required pam_limits.so
```

## Memory Management

Elasticsearch is configured with 1 GB heap memory by default. And this is apparently too small for production.

```shell
# set environment variable
export ES_HEAP_SIZE=10g
```

### Considerations

* Give (less than) Half Memory to Lucene
* No more than 32 GB ([compressed oops(ordinary object pointer)](https://wikis.oracle.com/display/HotSpotInternals/CompressedOops))
* How Far Under 32 GB Depends On JVM and OS

```shell
$ JAVA_HOME="$(/usr/libexec/java_home -v 1.7)" java -Xmx32666m -XX:+PrintFlagsFinal 2> /dev/null | grep UseCompressedOops
  bool UseCompressedOops   := true
$ JAVA_HOME="$(/usr/libexec/java_home -v 1.7)" java -Xmx32767m -XX:+PrintFlagsFinal 2> /dev/null | grep UseCompressedOops
  bool UseCompressedOops   = false
```

`elasticsearch-2.3.1/logs/elasticsearch-babel.log`

```log
[2016-05-18 15:31:57,088][INFO ][env    ] [elasticsearch-babel06] heap size [9.8gb], compressed ordinary object pointers [true]
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
   $ curl http://1.2.3.4:9200/_cat/count?pretty=true
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

## rsyslog

>
A logging system should be capable of avoiding message loss in situations where the server is not reachable. To do so, unsent data needs to be buffered at the client while the server is offline. Then, once the server is up again, this data is to be sent.
>
This can easily be acomplished by rsyslog. In rsyslog, every action runs on its own queue and each queue can be set to buffer data if the action is not ready. Of course, you must be able to detect that “the action is not ready”, which means the remote server is offline. This can be detected with plain TCP syslog and RELP, but not with UDP. So you need to use either of the two.
>
The rsyslog queueing subsystem tries to buffer to memory. So even if the remote server goes offline, no disk file is generated. File on disk are created only if there is need to, for example if rsyslog runs out of (configured) memory queue space or needs to shutdown (and thus persist yet unsent messages). Using main memory and going to the disk when needed is a huge performance benefit. You do not need to care about it, because, all of it is handled automatically and transparently by rsyslog.

[Reliable Forwarding of syslog Messages with Rsyslog](http://www.rsyslog.com/doc/v8-stable/tutorials/reliable_forwarding.html)

rsyslog 7.4.7

### bulid rsyslog 8.22.0

```shell
# download and install libfastjson (from rsyslog.com)
yum install libuuid-devel
export JSON_C_CFLAGS='-I/usr/local/include/libfastjson'
export JSON_C_LIBS='/usr/local/lib/libfastjson.so'
./configure --enable-elasticsearch
make -j 20
make install
```

### Priority

* The PRI value is a combination of so-called severity and facility.
* The so-called priority (PRI) is very important in syslog messages, because almost all filtering in syslog.conf is based on it.

### basic configure

```
$ModLoad imuxsock # local message reception
$WorkDirectory /rsyslog/work # default location for work (spool) files
$ActionQueueType LinkedList # use asynchronous processing
$ActionQueueFileName srvrfwd # set file name, also enables disk mode
$ActionResumeRetryCount -1 # infinite retries on insert failure
$ActionQueueSaveOnShutdown on # save in-memory data if rsyslog shuts down
*.* @@server:port
```

### client

```
# /etc/rsyslog.conf
module(load="imtcp")
# tcp
local0.*  @@remote-host:port
# udp
local0.* @remote-host:port
```

#### $MainMsgQueue

```
$MainMsgQueueFilename mainQ
$MainMsgQueueType LinkedList
$MainMsgQueueHighWatermark 5000
$MainMsgQueueLowWatermark 1000
$MainMsgQueueDiscardMark 150000
$MainMsgQueueQueueDiscardSeverity 3
$MainMsgQueueTimeoutEnqueue 1000
$MainMsgQueueMaxFileSize 100M
$MainMsgQueueMaxDiskSpace 1G
```

#### $ActionQueue

```
$ActionQueueFileName ackQ
$ActionQueueMaxDiskSpace 1G
$ActionQueueMaxFileSize 100M
$ActionQueueType LinkedList
$ActionResumeRetryCount -1
$ActionQueueDiscardMark 100000
$ActionQueueDiscardSeverity 3
$ActionQueueHighWatermark 3000
$ActionQueueLowWatermark 1000
$ActionQueueTimeoutEnqueue 200
$ActionDequeueBatchSize 200
```

#### Key Configuration

```
* <object>
	* MainMsg
	* Action
* $<object>QueueType
* $WorkDirectory
* $<object>QueueCheckpointInterval
* $<object>MainMsgQueueSaveOnShutdown on
* $<object>QueueSize
* Disk Queues
	* $<object>QueueType Disk
	* $<object>QueueFilename
	* $<object>QueueMaxFileSize
	* <object>QueueSyncQueueFiles on/off
* In-Memory Queues
	* $<object>QueueType LinkedList
	* $<object>QueueType FixedArray
* Disk-Assisted Memory Queues
	* $<object>QueueFileName
	* $<object>QueueHighWatermark
	* $<object>QueueLowWatermark
* $<object>QueueDiscardMark
* $<object>QueueDiscardSeverity
* $<object>QueueTimeoutEnqueue
* $<object>DequeueBatchSize
```

### module

```
module(load="imtcp")
module(load="omelasticsearch")
```

### template

```
# index name: /var/log/lambda-17-auth-server.log
template(name="lambda-omf" type="list") {
        constant(value="/var/log/lambda-")
        property(name="syslogfacility")
        constant(value="-")
        property(name="programname")
        constant(value=".log")
}
# index name: logstash-YYYY-MM-DD
template(name="lambda-idx" type="list") {
    constant(value="logstash-")
    property(name="timereported" dateFormat="rfc3339" postition.from="1" position.to="10")
}

# format syslog in json with @timestamp
template(name="lambda-log" type="list") {
    constant(value="{")
    constant(value="\"@timestamp\":\"") property(name="timereported" dateFormat="rfc3339")
	constant(value="\",\"@version\":\"1")
    constant(value="\",\"message\":\"")     property(name="msg" format="json")
    constant(value="\",\"hostname\":\"")       property(name="hostname")
    constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
    constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
    constant(value="\",\"tag\":\"")         property(name="syslogtag" format="json")
    constant(value="\",\"progname\":\"")    property(name="programname")
	constant(value="\",\"procid\":\"")      property(name="procid")
    constant(value="\"}")
}
```

### define ruleset and action

```
ruleset(name="lambda") {
local0.*        action(type="omfile" dynaFile="lambda-omf" FileCreateMode="0644")
local1.*        action(type="omfile" dynaFile="lambda-omf" FileCreateMode="0644")
local2.*        action(type="omfile" dynaFile="lambda-omf" FileCreateMode="0644")
        action(type="omelasticsearch"
                server="localhost"
                serverport="9200"
                template="lambda-log"
                searchIndex="lambda-idx"
                dynSearchIndex="on"
                searchType="events"
                bulkmode="on"
                timeout="1m"
                queue.type="linkedlist"
                queue.size="10000"
                queue.dequeuebatchsize="200"
                action.resumeretrycount="-1"
                errorfile="/var/log/lambda_err.log"
        )
}
```

* searchType="mycustomtype" - to specify a different type than "events". You can have dynSearchType="on" to have it variable, like you can with indices
* serverport="9200" - this is the default setting, but you can specify a different port
* asyncrepl="on" to enable asyncronous replication. That is, Elasticsearch gives an answer imediately after inserting to the main shard(s). It doesn't wait for replicas to be updated as well, which is the default setting
* timeout="1m" - how long to wait for a reply from Elasticsearch. More info here, near the end: http://www.elasticsearch.org/guide/reference/api/index_.html
* basic HTTP authentication. Elasticsearch has no authentication by default, but you can enable it:
* Elasticsearch can index multiple documents at a time (eg: in the same request), which makes this approach faster than indexing one log line at a time. You can make omelasticsearch use this feature by setting bulkmode="on" in your action() line.

### bind ruleset

```
input(type="imtcp" port="514" ruleset="lambda")
```

### configuring the centralized server to send to logstash

```
*.*  @logstash-ip:port;template-name
```

### configure logstash to receive json messages

```
# This input block will listen on port 10514 for logs to come in.
# host should be an IP on the Logstash server.
# codec => "json" indicates that we expect the lines we're receiving to be in JSON format
# type => "rsyslog" is an optional identifier to help identify messaging streams in the pipeline.

input {
  udp {
    host => "logstash_private_ip"
    port => 10514
    codec => "json"
    type => "rsyslog"
  }
}

# This is an empty filter block.  You can later add other filters here to further process
# your log lines

filter { }

# This output block will send all events of type "rsyslog" to Elasticsearch at the configured
# host and port into daily indices of the pattern, "rsyslog-YYYY.MM.DD"

output {
  if [type] == "rsyslog" {
    elasticsearch {
      hosts => [ "localhost:9200" ]
    }
  }
}
```

## Log Server Architecture

```
rsyslog1(client) --->|
rsyslog2(client) --->| --> rsyslog(reception) --> logstash -> elasticsearch
rsyslog3(client) --->|
```

* facility
	* local0(online)
	* local1(dev)
	* local2(test)
* tag
	* program name: control-server

## References

* [https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html)
* [Heap: Sizing and Swapping](https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html)
* [elasticsearch indexing performance cheatsheet](https://blog.codecentric.de/en/2014/05/elasticsearch-indexing-performance-cheatsheet/)
* [HOWTO: rsyslog + elasticsearch](http://wiki.rsyslog.com/index.php/HOWTO:_rsyslog_%2B_elasticsearch)
* [USING RSYSLOG MODULES](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-using_rsyslog_modules.html)
* [Tag Archives: logstash](http://www.rsyslog.com/tag/logstash/)
* [How To Centralize Logs with Rsyslog, Logstash, and Elasticsearch on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-centralize-logs-with-rsyslog-logstash-and-elasticsearch-on-ubuntu-14-04)
* [http://unix.stackexchange.com/questions/65595/how-to-know-if-a-disk-is-an-ssd-or-an-hdd](http://unix.stackexchange.com/questions/65595/how-to-know-if-a-disk-is-an-ssd-or-an-hdd)
* [https://wiki.debian.org/SSDOptimization](https://wiki.debian.org/SSDOptimization)
