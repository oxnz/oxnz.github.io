---
title: Elasticsearch - benchmark
---

## Table of Contents

* TOC
{:toc}

<!--more-->

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

    ____        ____
   / __ \____ _/ / /_  __
  / /_/ / __ `/ / / / / /
 / _, _/ /_/ / / / /_/ /
/_/ |_|\__,_/_/_/\__, /
                /____/

 You know for benchmarking Elasticsearch.

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  --advanced-config     show additional configuration options (default: false)
  --assume-defaults     Automatically accept all options with default values
                        (default: false)
  --pipeline PIPELINE   select the pipeline to run.
  --preserve-install PRESERVE_INSTALL
                        keep the benchmark candidate and its index. (default:
                        false)
  --telemetry TELEMETRY
                        enable the provided telemetry devices, provided as a
                        comma-separated list. List possible telemetry devices
                        with `esrally list telemetry`
  --revision REVISION   define the source code revision for building the
                        benchmark candidate. 'current' uses the source tree as
                        is, 'latest' fetches the latest version on master. It
                        is also possible to specify a commit id or a
                        timestamp. The timestamp must be specified as: "@ts"
                        where "ts" must be a valid ISO 8601 timestamp, e.g.
                        "@2013-07-27T10:37:00Z" (default: current).
  --track TRACK         define the track to use. List possible tracks with
                        `esrally list tracks` (default: geonames).
  --challenge CHALLENGE
                        define the challenge to use. List possible challenges
                        for tracks with `esrally list tracks` (default:
                        append-no-conflicts).
  --car CAR             define the car to use. List possible cars with
                        `esrally list cars` (default: defaults).
  --target-hosts TARGET_HOSTS
                        define a comma-separated list of host:port pairs which
                        should be targeted iff using the pipeline 'benchmark-
                        only' (default: localhost:9200).
  --client-options CLIENT_OPTIONS
                        define a comma-separated list of client options to
                        use. The options will be passed to the Elasticsearch
                        Python client (default:
                        timeout:60000,request_timeout:60000).
  --user-tag USER_TAG   define a user-specific key-value pair (separated by
                        ':'). It is added to each metric record as meta info.
                        Example: intention:baseline-ticket-12345
  --report-format {markdown,csv}
                        define the output format for the command line report
                        (default: markdown).
  --report-file REPORT_FILE
                        write the command line report also to the provided
                        file
  --quiet               suppress as much as output as possible (default:
                        false).
  --laps LAPS           number of laps that the benchmark should run (default:
                        1).
  --distribution-version DISTRIBUTION_VERSION
                        define the version of the Elasticsearch distribution
                        to download. Check
                        https://www.elastic.co/downloads/elasticsearch for
                        released versions.
  --distribution-repository {snapshot,release}
                        define the repository from where the Elasticsearch
                        distribution should be downloaded (default: release).
  --track-repository TRACK_REPOSITORY
                        define the repository from where Rally will load
                        tracks (default: default).
  --offline             assume that Rally has no connection to the Internet
                        (default: false)

subcommands:
  {race,list,compare,configure}
    race                Run the benchmarking pipeline. This sub-command should
                        typically be used.
    list                List configuration options
    compare             Compare two races
    configure           Write the configuration file or reconfigure Rally

Find out more about Rally at https://esrally.readthedocs.io/en/0.4.5/
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

### Graph Results

The final element you need to add to your Test Plan is a Listener. This element is responsible for storing all of the results of your HTTP requests in a file and presenting a visual model of the data.

Add → Listener → Graph Results

### View Results in Table

### View Results Tree

### Errors

HTTP Error Code | Reason
429 | Too many requests
503 | Service unavailable

### Glossary

Throughput

Throughput is calculated as requests/unit of time.

Throughput = (number of requests) / (total time).

### Example

```shell
./apache-jmeter-3.1/bin/jmeter -n -t testplan.jmx
```

Result:

HEAP_SIZE | Concurrency | Throughput | Avg | Min | Max      | Err
:--------:|:-----------:|:----------:|:---:|:---:|:--------:|:----:
2G        | 48          | 1100       | 40  | 4   | 155/1082 | 6~25%
4G        | 48          | 1000       | 45  | 6   | 154/439  | 5.7%
6G        | 48          | 1000       | 47  | 6   | 200      | 5.8%
8G        | 48          | 850        | 55  | 6   | 200/400  | 5.8%
10G       | 48          | 830        | 57  | 6   | 200/600  | 5.6%
12G       | 48          | 600        | 60  | 7   | 200/1000 | 5.8%

## NO. of shard and replica

node (core x 48) x 7

300,000 docs (600M)

nshard | nreplica | nsegment | concurrency | delay
:---------:|:------------:|:-----------:|:------:
1 | 0 | 17 | 180 | 350
1 | 1 | 17 | 360 | 175
1 | 2 | 17 | 540 | 117
1 | 3 | 17 | 720 | 88
1 | 4 | 17 | 860 | 73
1 | 5 | 17 | 1020 | 62
1 | 6 | 17 | 1170 | 54
1 | 0 | 1 | 200 | 315
1 | 1 | 1 | 400 | 155
1 | 6 | 1 | 1300 | 49
2 | 0 | 12 | 363 | 174
2 | 0 | 2 | 390 | 162
2 | 1 | 2 | 760 | 83
2 | 2 | 2 | 1100 | 57
2 | 3 | 2 | 790 | 80
2 | 4 | 2 | 960 | 66
2 | 5 | 2 | 1120 | 56
2 | 6 | 2 | 1300 | 48
3 | 0 | 3 | 570 | 111
3 | 1 | 3 | 1070 | 59
3 | 2 | 3 | 880 | 71
3 | 4 | 3 | 980 | 64
4 | 0 | 4 | 720 | 86
4 | 1 | 4 | 780 | 80
4 | 2 | 4 | 1050 | 59
4 | 3 | 4 | 1000 | 63
5 | 0 | 5 | 850 | 74
5 | 1 | 5 | 920 | 69
5 | 2 | 5 | 950 | 66
5 | 3 | 5 | 1130 | 55
5 | 4 | 5 | 1110 | 57
6 | 0 | 6 | 950 | 66
6 | 1 | 6 | 1020 | 62
6 | 2 | 6 | 1060 | 59
6 | 3 | 6 | 1080 | 57
6 | 4 | 6 | 1120 | 56
7 | 0 | 7 | 1040 | 61
7 | 1 | 7 | 1120 | 56
7 | 2 | 7 | 1150 | 55
7 | 4 | 7 | 1160 | 55

## References

* [https://github.com/elastic/rally](https://github.com/elastic/rally)
* [http://jmeter.apache.org/usermanual/test_plan.html](http://jmeter.apache.org/usermanual/test_plan.html)
