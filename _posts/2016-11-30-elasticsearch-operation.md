---
title: Elastcisearch operation
---

Common Elasticesarch operations

<!--more-->

## Table of Contents

* TOC
{:toc}

## Cluster

### Reset cluster settings

#### Before 5.0

```
PUT _cluster/settings
{
    "transient": {
        "cluster.routing.allocation.enable": ""
    }
}
```

#### After 5.0

```
PUT _cluster/settings
{
    "transient": {
        "cluster.routing.allocation.enable": null
    }
}
```

## Scripting

### Sorting

```
"sort": {
    "_script": {
        "script": "doc['score']*0.85",
        "lang": "groovy",
        "type": "number",
        "order": "asc"
    }
}
```

### Computing return fields

```
"script_fields": {
    "computed_field": {
        "script": "doc['name'].value + ' - ' + doc['desc'].value"
    }
}
```

### Filtering

```
"filtered": {
    "filter": {
        "script": {
            "script": "doc['updated'] > ts",
            "params": { "ts": 14000000 }
        }
    }
}
```

## Index

```shell
curl -XPUT "$(hostname -I):9200/articles/_settings" -d \
    '{"index": {"number_of_shards":5}}'
curl -XPUT "$(hostname -I):9200/articles/_settings" -d \
    '{"index": {"number_of_replicas":2}}'
```
