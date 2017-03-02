---
title: Elasticsearch - Performance Tuning
---

![elasticsearch](/assets/elasticsearch.jpg)

<!--more-->

## Table of Contents

* TOC
{:toc}

## Preparation

### measurements

* concurrency
* latency

simulate production envfilter and queries

### clean cache

#### clean elasticsearch cache

```
POST posts/_cache/clear
```

#### clean system cache

The kernel documentation says:

drop_caches

Writing to this will cause the kernel to drop clean caches, dentries and
inodes from memory, causing that memory to become free.

* To free pagecache:
    * echo 1 > /proc/sys/vm/drop_caches
* To free dentries and inodes:
    * echo 2 > /proc/sys/vm/drop_caches
* To free pagecache, dentries and inodes:
    * echo 3 > /proc/sys/vm/drop_caches

As this is a non-destructive operation and dirty objects are not freeable, the
user should run `sync` first.

## Rally

### Usage

```console
oxnz@ubuntu-vm:~$ .local/bin/esrally -h
usage: esrally [-h] [--version] [--advanced-config] [--assume-defaults]
               [--pipeline PIPELINE] [--preserve-install PRESERVE_INSTALL]
               [--telemetry TELEMETRY] [--revision REVISION] [--track TRACK]
               [--challenge CHALLENGE] [--car CAR]
               [--target-hosts TARGET_HOSTS] [--client-options CLIENT_OPTIONS]
               [--user-tag USER_TAG] [--report-format {markdown,csv}]
               [--report-file REPORT_FILE] [--quiet] [--laps LAPS]
               [--distribution-version DISTRIBUTION_VERSION]
               [--distribution-repository {snapshot,release}]
               [--track-repository TRACK_REPOSITORY] [--offline]
               {race,list,compare,configure} ...
```

### Example

```shell
.local/bin/esrally --distribution-version=2.4.2 --trace tiny
```

## JMeter

### Thread Group

Thread group elements are the beginning points of any test plan.

The first step you want to do with every JMeter Test Plan is to add a Thread Group element.

Ramp-Up Period
: This property tells JMeter how long to delay between starting each user.

Loop Count
: how many times to repeat your test.

### HTTP Header Manager

Add -> Config Elemenet -> HTTP Header Manager

```
Content-Type: application/json
```

### HTTP Request Defaults

Add → Config Element → HTTP Request Defaults

The HTTP Request Defaults element does not tell JMeter to send an HTTP request. It simply defines the default values that the HTTP Request elements use.

### HTTP Authorization Manager

Add → Config Element → HTTP Authorization Manager

Key      | Value
:-------:|:-----------------------:
Base URL | http://10.0.0.123:8080/
Username | oxnz
Password | 123456

### CSV Data Set Config

Add → Config Element → CSV Data Set Config

### HTTP Request

JMeter sends requests in the order that they appear in the tree.

Add → Sampler → HTTP Request

```
${qw}
${__Random(1, 100)}
```

### Graph Results

The final element you need to add to your Test Plan is a Listener. This element is responsible for storing all of the results of your HTTP requests in a file and presenting a visual model of the data.

Add → Listener → Graph Results

### View Results in Table

### View Results Tree

### Errors

HTTP Error Code | Reason
----------------|--------
429 | Too many requests
503 | Service unavailable

### Glossary

Throughput

Throughput is calculated as requests/unit of time.

Throughput = (number of requests) / (total time).

### Example

```shell
./apache-jmeter-3.1/bin/jmeter -n -t testplan.jmx -l testplain.jtl
```

```
-n non-gui mode
-t name of JMX file that contains the Test Plan
-l name of JTL file to log sample results to
```

### Advanced Topics

#### Writing JUnit TestCase to benchmark

Result:

HEAP_SIZE | Concurrency | Throughput | Avg | Min | Max      | Err
:--------:|:-----------:|:----------:|:---:|:---:|:--------:|:----:
2G        | 48          | 1100       | 40  | 4   | 155/1082 | 6~25%
4G        | 48          | 1000       | 45  | 6   | 154/439  | 5.7%
6G        | 48          | 1000       | 47  | 6   | 200      | 5.8%
8G        | 48          | 850        | 55  | 6   | 200/400  | 5.8%
10G       | 48          | 830        | 57  | 6   | 200/600  | 5.6%
12G       | 48          | 600        | 60  | 7   | 200/1000 | 5.8%

## Slow Log

```http
PUT mugc_search/_settings
{
  "index.search.slowlog.threshold.query.warn": "140ms",
  "index.search.slowlog.threshold.fetch.warn": "30ms",
  "index.indexing.slowlog.threshold.index.warn": "500ms"
}
```

## Limit

TooManyClausesmultiplication

```
index.query.bool.max_clause_count: 1024
```

## System Metrics

使用一些工具或者脚本收集系统运行过程中的一些数据，可以方便分析问题。

### script

```shell
vmstat 1 5 | awk 'BEGIN { line=0; total=0; } { 
line=line+1; if(line>1) { total=total+\$16; }} END{ print total/4 }'
```

### vmstat index

```shell
vmstat -n -t 1 > vmstat.out
python index.py | sh
```

```python
import json

def index(line):
    parts = line.split()
    record = {
            'r': parts[0],
            'b': parts[1],
            'swpd': parts[2],
            'free': parts[3],
            'buff': parts[4],
            'cache': parts[5],
            'si': parts[6],
            'so': parts[7],
            'bi': parts[8],
            'bo': parts[9],
            'in': parts[10],
            'cs': parts[11],
            'us': parts[12],
            'sy': parts[13],
            'id': parts[14],
            'wa': parts[15],
            'st': parts[16],
            'ts': parts[17] + ' ' + parts[18] + ' +0800'
            }
    index_api = 'localhost:9200/perf/doc'
    print "curl -XPOST '{}' -d '{}'".format(index_api, json.dumps(record))

with open('vmstat.out') as f:
    map(index, f)
```

## shard, replica and segment

![Elasticsearch Benchmark](/assets/elasticsearch-benchmark.svg)

* exploit more CPU with additional shards

### Replica

* using replicas to reduce query contention
* impact the performance of data ingestion
* only benifit if replicas are distributed across nodes

## CPU

### hot thread

```http
GET _cat/thread_pool?v
```

```http
GET _nodes/hot_threads
```

## Search

### Testing and analyzing search performance

* concurrency and latency should be considered together
* CPU processing and I/O wait times, disk latency, throughput, and response times
    * reading, writing (IOPS)
    * throttled by VM manager if in VM env
    * identify potential bottlenecks and assess the costs and benefits of using premium hardware
    * CPU and disk utilization might not be even across all nodes
* consider how the number of concurrent requests for the workload will be distributed across the cluster and assess the impact of using different numbers of nodes to handle this workload
* consider how wordloads might grow as the business expands
    * assess the impact of this growth on the costs of the CPU and storage used by the nodes
* increasing the number of nodes can introduce overhead in the form of additional inter-node communications and synchronization
* sometimes what is good for query detrimental can have an negtive impact on insertion operations, and vice versa.

![Elasticsearch Benchmark](/assets/elasticsearch-benchmark-timecost.svg)

### Pre-loading data into the file system cache

```http
PUT /posts-index
{
  "settings": {
    "index.store.preload": ["nvd", "dvd"]
  }
}
```

* nvd: norms
* dvd: doc values
* tim: terms dictionaries
* doc: postings lists
* dim: points

The default value is the empty array, which means that nothing will be loaded into the file-system cache eagerly.

>
Note that this setting can be dangerous on indices that are larger than the size of the main memory of the host, as it would cause the filesystem cache to be trashed upon reopens after large merges, which would make indexing and searching slower.

### the shard request cache

Elastic can cache the local data requested by queries on each shard in memory

* the risk that data served from the cache is outdated
    * the data in the cache is only invalidated when the shard is refreshed and the data has changed.
    * the frequency of refreshes is governed by `refresh_interval` settings of the index

the request caching for an index is disabled by default

```http
PUT /posts-index/_settings
{
  "index.requests.cache.enable": true
}
```

the shard request cache is most suitable for information that remains relatively static, such as historical or logging data.

### client nodes

All queries are processed by the node that first receives the request

* creating a pool of client nodes to alleviate the load from the data nodes, if the queries are a small set of complex queries
* using a load balancer to distribute the requests evenly to data nodes directly if queries are a large number of simple queries

### Tuning queries

**Be cautious of detune**

* Avoid queries that invole wildcards whenever possible
* If the same field is subject to full-text searching and exact matching, then consider storing the data for the field in analyzed and non_analyzed forms.
Perform full-text searches against the analyzed field and exact matches against the non-analyzed field
* Queries return the data necessary
    * `_source: false`: reduce disk I/O
    * field_filter: reduce bandwidth
* Use filteres instead of queries when searching data whenever possible
* Use bool filters for performing static comparisons, and only use `and`, `or`, and `not` filters for dynamically calculated filters, such as those that invole scripting or the `geo-*` filters
* If a query combines bool filters with `and`, `or`, or `not` with `geo-*` filters, place the `and`/`or`/`not` `geo-*` filters last so that they operate on the smallest data set possible
* Similarily, use a post_filter to run expensive filter operations, these filters will be performed last
* Use the cardinality aggregation in preference to the value_count aggregation unless an exact count of matching items is required
    * exact value can became quickly outdated
    * many applications only require a reasonable approximation
* Avoid scripting
    * expensive
    * not cached
    * consume search thread long period, futher requests would be rejected when queue fills up

### concurrency and latency

延迟会随着并发量减少而减小，反之亦然。

### Ramdisk

```shell
mkdir -p /dev/shm/elasticsearch/{data,logs}
```

### shard

```http
POST /posts_index/_forcemerge?max_num_segments=1
```

shard 太少导致性能下降

### search_type

* query_then_fetch
* dfs_query_then_fetch

可以新增加类型来满足不同的搜索需求，比如去掉fetch phase来提高性能。

### search queue

基本无影响

### Interrupt CPU Affinity

基本无影响，但是 cs (context switches) 比较高，系统 （sys）时间占比达到 10%

### segment

一定情况下会随着 segment 数目减少而提升性能，但是少到一定数量（4）个之后，基本五影响。

### index.codec

best_compression 压缩比增加，减少空间，增加 CPU 消耗。归档冷数据可考虑。

### split index

Prefer separate indexes for different types that storing multiple types in one index

* Different types might specify different analyzers, may be confused if a query is performed at the index level rather than at the type level
* Shards for indexes that holds multiple types will likely be bigger that those for indexes that contains a single type
* Information for one type can became sparsely distributed across many shards, reducing the effeciency of searches that receives this data if there is a significant mismatch between data volumes for the types
* small shards can be more evenly distributed than large shards, making it easier for Elasticsearch to spread the load across nodes
* Different types may have different retention period. It can be difficult to archive old data that shares shards with active data

but hold multiple types of document in one index still can be benifit if

* searches regularly span types hold in the same index
* the types only have a small number of documents each

增加并发，降低延迟，更充分利用CPU资源

可以按照数据类型、冷热数据等不同条件来做拆分，具体条件要视具体应用来定。如果多种方案可行，可以测试不同的分类带来的性能等影响进行评估。

### post_filter

### Response filtering

过滤返回结果: 1030 QPS -> 1130 QPS (increse by 10%)

```http
POST video-index/movie/_search?filter_path=hits.hits._id,hits.hits._score
```

### percolate

可以使用 percolate 来检验缓存是否实效

比如索引或者更新了一个doc，检测这个doc是否需要去更新缓存，就可以在索引中索引查询，使用新的doc来匹配查询，对匹配到的查询进行cache invalidate或者更新缓存

## Elasticsearch v.s. Database

* Database cannot combine index dynamically, it will pick the "best" one, and then try to resolve the other criteria the hard way
* elasticsearch have filter cache

## Index

The number of shards determines the capacity of the index.

create more shards than nodes:

* no need to reindex when new nodes was added
* each shard is implemented as a separate lucene index, and has its own internal mechanisms for maintaining consistency and handling concurrency.
* creating multiple shards helps to increase parallelism within a node and can improve performance
* the more nodes and shards a cluster has, the more effort required to synchoronize

### Data Source Speed

#### Read from Database

DB 优化可以参考之前mysql优化文章

数据库可以使用全量表结合增量表的设计，增量表可以维护多张表，隔天合并到全量表，表的切换可以使用alias来处理。这样以来就不用抓数据应用和索引应用同时写表，降低耦合，提神性能。

DB 数据量大可以采用分区方式：

partition

* hash
* list

也可以使用merge引擎，但是有限制，比如使用MyISAM引擎等。

分库的话logstash的jdbc插件不能支持多库，需要写脚本来多次执行。

数据转换可能消耗比较多系统资源，可以使用多个节点来同时进行，提高索引速度。

可以根据WHERE条件进行过滤，拆分索引

从 DB 到redis （11w/s)

另外从DB到es或者redis可以使用logstash，不用开发，而且可以控制速度和并发:

* input: jdbc
* output
    * redis
    * elasticsearch

### Ingest Speed

Increasing the number of queues and/or the length of each queue might reduce the number of errors, but this approach can only cope with bursts of short duration.
Doing this while running a sustained services of data ingestion tasks will simply delay the point at which errors start occurring.
Further more, this change will not improve the throughput and will likely harm the response time of client applications as requests will be queued for longer before being processed

This is also true for query queues.

#### mapping

Elasticsearch uses mappings to determine how to interpret the data that occurs in each field in a document.

each type has its own mapping, which effectively defines a schema for that type.
Elastic uses this information to generate inverted indexes for each field in the documents in a type.

In any documents, each field has a data type (string, date, integer) and a value.

* Mappings generated dynamically can cause errors depending on how fields are interpretted when documents are added to an index
* Design your documents to avoid generating excessively large mappings as this can add significant overhead when performing searches, cosume lots of memory, and also cause queries to fail to find data (mapping explosion)
* use not_analyzed to avoid tokenization where appropriate (find exact values)


可以精简字段，预先计算多个字段，例如根据不同的维度计算出一个quality字段供查询使用。

可以使用精细粒度的控制，比如是否索引，是否存储，是否包含在 _all 字段里。

stored_fields
: retrieve the stored fields without having to extract those fields from a large _source field

another situation where it can make sense to make a field stored is for those that don't appear in the _source field (copy_to)

doc_values
: on-disk data structure, built at index time. Sorting, aggregations and access to field values in scripts requires to be able to look up the document and find the terms that it has in a field. They store the same values as the _source but in a column-oriented fashion which is more effecient for sorting and aggregations. Doc values are supported on almost all field types without analyzed string fields.

fielddata
: text field do not support doc_values, instead, text fields use a query time in-memory data structure called fielddata. This data structure is built on demand the first time that a field is used for aggragations, sorting or in a script. It is built by reading the entire inverted index for each segment from disk. inverting the term <-> document relationship, and storing the result in memory, in the JVM heap. disabled by default.

Global ordinals is a data structure on top of fielddata and doc values, that maintains an incremental numbering order. for each unique term in a lexigraphic.

doc_values store on disk and is contructed when data is indexed, while fielddata is constructed dynamically when a query is performed

#### CPU Affinity

几乎没有影响

* analysis
* bulk
* thread_pool
* queue
* disk I/O

![Elasticsearch Benchmark](/assets/elasticsearch-benchmark-index.svg)

```shell
watch -n 1 'curl -s "$(hostname -I):9200/_cat/indices?v" | tee -a index.log'
```

* concurrency
* threshold
* merge
* kafka
* translog
    * durability
        * async
    * sync_interval
    * flush_threshold_size
    * flush_threshold_opts
* refresh_interval
* index_buffer_size
* bulk

refresh is an expensive operation. when in index stage, temporarily disabling index refreshes to gain performance.

```http
PUT /mugc_index
{
  "settings": {
    "refresh_interval": -1
  }
}
```

disabling replication during bulk import operations and then reenable it when the import is complete:

```http
PUT /perf_index
{
  "settings": {
    "number_of_replicas": 0
  }
}
```

disabling data ingestion throttling to maximize performance:

```http
PUT /_cluster/settings
{
  "transient": {
    "indices.store.throttle.type": "none"
  }
}
```

set the throttle type of the cluster back to "merge" when ingestion has completed.

### shard

增加shard数目可以增加index速度

### _reindex

reindex is needed for:

* inaccurate estimate
* data grows
* not necessary for data that ages quickly (log, audit data)
* to remains searchable while reindexing, search through aliases. create aliases for each index

![Elasticsearch Benchmark](/assets/elasticsearch-benchmark-reindex.svg)

refresh_interval set to -1: 110k/s -> 130k/s

tasks after _reindex:

* `_forcemerge?max_num_segments=1`
* `refresh_interval=30`

### _shrink index

### Translog

>
Changes to Lucene are only persisted to disk during a Lucene commit, which is a relatively heavy operation and so cannot be performed after every index or delete operation.

```
index.translog.flush_threshold_size (512mb by default)
```

index.translog.durability

* async: every 5 seconds
* request (default) at the end of every index, delete, update or bulk request

index.translog.sync_interval
: how often the translog is fsync ed to disk and committed

## Fields

### doc_values

many queries and aggregations require that data is sorted as part of the search operation

sorting requires being able to map one or more terms to a list of documents.

To assist in this process, Elastic can load all of the values for a field used as a sort key into memory.
This is known as fielddata

* less I/O overhead
* if a field has high cardinality, consume a lot of heap space

doc_values as an alternative approach.

视具体query而定。对于没有aggregation，sort等的query而言是否启用doc_values基本上没有影响。

### `_source`

* A copy of the original JSON document
* not searchable
* but by default returned by GET and search requests
* This field incurs overhead and occupies storage
    * making shards larger and increasing the volume of I/O performed.

#### Source Filtering

control how the `_source` field is returned with every hit

* return the contents of the `_source` field by default
* disable `_source` retrieval

```http
GET /_search
{
    "_source": false,
    "query": {
...
```

Disable by mapping:

```
"_source": { "enabled": false }
```

disable _source also removes these abilities:

* updating data in the index by using the update API
* perform searches that return highlighted data
* reindexing
* changing mappings or analysis settings
* debugging queries by viewing the original document

180 QPS, 320ms latency -> 870 QPS, 72ms latency (1/4 docs)

* reduce store size
* increse performance

use source filter (9/16) instead of return entire _source: 500 QPS -> 1020 QPS

### `_all`

* pros
    * 无需指定搜索字段
    * 可以使用 _all 字段 filter，减少需要进行 score 的文档数来提升性能
    * 综合各个字段的boost （如果一个字段的boost大于另一个，那么这个字段在 _all 字段中的权重也大于另一个字段
* cons
    * 增加索引大小
    * 由于 _all 字段不存储，所以无法支持高亮
    * 没有lengthNorm，所有命中 _all 字段的lengthNorm都一样

## score scripts

### lucene expression

fatest

### painless

mush faster

### groovy

slowest

## Query

### Template

[https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html)

870 QPS -> 930 QPS

### filter

filter cache

可根据实际情况增加 filter ，虽然会增加 filter 的时间消耗，但是换来的是score和排序的数据量减少，而后者消耗相比 filter 逻辑更为复杂, 尤其是在涉及到 script 时候。

### sort

* sort by `_doc` (the index order, no sort cost)
    * 200ms -> 50ms

### Rescoring

[https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-rescore.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-rescore.html)

> Rescoring can help to improve precision by reordering just the top (eg 100 - 500) documents returned by the query and post_filter phases, using a secondary (usually more costly) algorithm, instead of applying the costly algorithm to all documents in the index.

### routing

## JVM

### GC

#### CMS

#### G1

#### Issues

```
[2017-01-12T10:34:31,432][WARN ][o.e.m.j.JvmGcMonitorService] [node-data-100.11.22.33] [gc][62583] overhead, spent [661ms] collecting in the last [1.2s]
```

Check if using a lot of fielddata (i.e. per-doc field values loaded for sorting, aggs, or scripting).

If so, consider switching those fields to use `doc_values: true` (reindex needed) to shift the memory use from heap to the file system cache.

```http
GET /_nodes/stats/indices/fielddata?fields=*&human&pretty
```

### Instance vs HEAP_SIZE

## Strategies

### Cache and Async Search

异步 Query，查询结果放在缓存系统中，这样可以支持较高的并发量。

缓存 invalidate 可以使用不同的策略，最基本可以使用 LRU 加超时。
高级一点可以对 cache 中的所有条目建立基于 term 的倒排索引，等到索引更新或者增加文档的时候，根据文档中所包含的 term 进行 invalidate 操作。

### Space for Time or vice versa

可以存储更多的数据来节省查询时的计算

## Memos

* segment 数目
* shard 数目
* interrupt CPU affinity
* search queue
* _source
* script
* _all
* index speed
* concurrency and latency
* doc_values
* refresh_interval
* translog
	* durability: “async”
	* sync_interval
	* flush_threshold_size

## References

* [https://github.com/elastic/rally](https://github.com/elastic/rally)
* [http://jmeter.apache.org/usermanual/test_plan.html](http://jmeter.apache.org/usermanual/test_plan.html)
* [http://jmeter.apache.org/usermanual/best-practices.html](http://jmeter.apache.org/usermanual/best-practices.html)
* [https://www.kernel.org/doc/Documentation/sysctl/vm.txt](https://www.kernel.org/doc/Documentation/sysctl/vm.txt)
* [https://docs.microsoft.com/en-us/azure/guidance/guidance-elasticsearch](https://docs.microsoft.com/en-us/azure/guidance/guidance-elasticsearch)
* Lucene In Action
* Elasticsearch
* Solr
* SolrCloud
* Lucene
