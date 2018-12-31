---
title: Elasticsearch Customization
---

Elasticsearch Customization

<!--more-->

## Table of Contents

* TOC
{:toc}

## Setup Dev Env

### IDE

IntelliJ IDEA

Remote -> port:8000

### Command Line

buildSrc/src/main/groovy/org.elasticsearch.gradle.test/ClusterFormationTasks.groovy:

commented out:

* checkPrevious
* stopPrevious

start up debug:

```
gradle run --debug-jvm
```

## Infrastructure

* org.elasticsearch.bootstrap
    * Elasticsearch
* org.elasticsearch.cli
    * Command
    * SettingCommand

Elasticsearch -> execute -> Bootstrap.init (setup, start) -> node.start ->

* nodeConnectionService.start
* tribeService.start
* transportService.start
* clusterService.start
* discovery.start
* transportService.acceptIncommingRequests
* discovery.startInitialJoin
* httpServer.start
    * RestController
        * rest.action
            * rest.action.cat (AbstractCatAction)
* tribeService.startNodes

## Search

* SearchQueryThenFetchAsyncAction
    * moveToSecondPhase
* SearchPhaseController
    * merge
* InternalSearchResponse
* rest.search.RestSearchAction
    * parseSearchRequest
* ActionModule
    * es.action.search.TransportSearchAction
        * Query_Then_Fetch
        * Query_AND_Fetch
        * DFS_Query_Then_Fetch
        * DFS_Query_AND_Fetch
* Plugin.java
    * ActionPlugin
    * SearchPlugin
* TransportClient.Java

coordrank -> improve precision

* o.e.indices.fielddata.cache.IndicesFieldDataCache
    * RemovableListener
    * Reusable
    * IndicesFielddata
    * Accountable

```java
SettingsMemorySiteSetting("indices.fielddata.cache.size").NodeScope.CacheBuilder.build()
```

