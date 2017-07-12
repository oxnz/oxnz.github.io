---
title: Elasticsearch
---

Elasticsearch API.

<!--more-->

## Python

```python
import elasticsearch
import elasticsearch.helpers

es = elasticsearch.Elasticsearch(
		hosts='1.2.3.4',
		sniff_on_start=True,
		sniff_on_connection_fail=True,
		sniffer_timeout=60
		)
actions = ({
'_op_type': 'index',
'_index': 'test',
'_type': 'doc',
'_id': msg.uid,
'doc': google.protobuf.json_format.MessageToJson(msg)
} for msg in pbmsgs)
elasticsearch.helpers.bulk(es, actions)
```

## Cautious

field type `long` is `signed long`, would overflow with MySQL bigint

```sql
select cast(id as CHAR(20)) from `table`
```

`CONVERT(expr, type)` ==(equivalent) `CAST(expr as type)`

## References

* [elasticsearch-py.readthedocs.io](http://elasticsearch-py.readthedocs.io/en/master/helpers.html)
