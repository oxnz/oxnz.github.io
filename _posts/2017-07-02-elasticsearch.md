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
doc = json.loads(google.protobuf.json_format.MessageToJson(msg))
doc = decode_base64(doc)
actions = ({
'_op_type': 'index',
'_index': 'test',
'_type': 'doc',
'_id': msg.uid,
'doc': doc
} for msg in pbmsgs)
elasticsearch.helpers.bulk(es, actions)
```
