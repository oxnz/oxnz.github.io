---
title: Elasticsearch Query
---

## Table of Contents

* TOC
{:toc}

<!--more-->

## Query DSL

AST of queries:

* Leaf Query Clauses
: look for a particular value in a particular field
    * match
    * term
    * range
* Compound Query Clauses
: wrap other leaf or compound queries and are used to combine multiple queries in a logical fashion or to alter their behavior
    * bool
    * dis_max
    * constant_score

Query clauses behave differently depending on whether they are used in query or filter context.

### Full text queries

* match
: including fuzzy matching and phrase or proximity queries
* match_phrase
: used for match exact phases or word proximity matches
* match_phrase_prefix
* multi_match
: multi-field version of the match query
* common_terms
: gives more preference to uncommon words
    * cutoff_frequency (0.0 .. 1.0)
    * document frequencies are computed on a per shard level
    * if a query consists only of high frequency terms, then a single query is executed as an AND (conjunction) query (all terms are required)
    * minimum_should_match
    * adapts to domain specific stopwords automatically
* query_string
: supports the compact Lucene query string syntax
* simple_query_string

```json
GET /_search
{
    "query": {
        "common": {
            "body": {
                "query": "how not to be",
                    "cutoff_frequency": 0.001,
                    "minimum_should_match": {
                        "low_freq" : 2,
                        "high_freq" : 3
                    }
            }
        }
    }
}
```

### Term level queries

* term
* terms
* range
* exists
* prefix
* wildcard
* regexp
* fuzzy
* type
* ids

```http
GET /_search
{
  "query": { "exists": { "field": "timestamp" } }
}

GET /_search
{
  "query": { "bool": { "must_not": { "exists": { "field": "timestamp" } } } }
}
```

### Compound queries

* constant_score
: all matching documents are given the same 'consant' score
* bool
    * leaf
    * have their score combined (the more matching clauses, the better)
        * must
        * should
    * executed in filter context
        * must_not
        * filter
* dis_max
: attempts multiple queries, and returns any documents which match any of the query clauses. while the `bool` query combines the scores from all matching queries, the `dis_max` query uses the score of the single best-matching query clause.

### Joining queries

* netsted
: nested field documents
* has_child
* has_parent

### Geo queries

* Geo Shape
* Geo Bounding Box
* Geo Distance
* Geo Distance Range
* Geo Polygon

### Specialized queries

* more_like_this
* template
: mustuche template
    * inline
    * indexed
    * file
* script
: this query allows a script act as a filter (function_score)
* percolate
: this query finds queries that are stored as documents that match with the specified document

### Span queries

Span queries are low-level positional queries which provide expert control over the order and proximity of the specified terms.
Usually used to implement very specific queries on legal docs or patents.

* span_term
* span_multi
* span_first
* span_near
* span_or
* span_not
* span_containing
* span_within
* field_masking_span

## Concrete Query

### Original

```json
{
  "explain": false,
  "from": 0,
  "size": 50,
  "timeout": "800ms",
  "query": {
    "template": {
      "params": {
        "query": "Q"
      },
      "inline": {
        "function_score": {
          "script_score": {
            "script": {
              "file": "score2",
              "params": {
                "t_normalize": 1,
                "t_weight": 1,
                "q_weight": 0,
                "f_weight": 0,
                "timestamp": 1480332107
              }
            }
          },
          "query": {
            "bool": {
              "minimum_number_should_match": 1,
              "should": [
                {
                  "multi_match": {
                    "query": "{{ query }}",
                    "fields": [
                      "title^3",
                      "alias",
                      "actors^3"
                    ],
                    "use_dis_max": true,
                    "type": "best_fields",
                    "tie_breaker": 0.3,
                    "minimum_should_match": "2",
                    "operator": "or",
                    "boost": 5
                  }
                },
                {
                  "multi_match": {
                    "query": "{{ query }}",
                    "fields": [
                      "title^3",
                      "alias"
                    ],
                    "use_dis_max": true,
                    "type": "best_fields",
                    "tie_breaker": 0.7,
                    "minimum_should_match": "1",
                    "operator": "or",
                    "boost": 0.01
                  }
                }
              ],
              "filter": {
                "bool": {
                  "must": [
                    {
                      "multi_match": {
                        "query": "{{query}}",
                        "fields": [ "title", "actors", "alias" ],
                        "minimum_should_match": 1
                      }
                    }
                  ]
                }
              }
            }
          },
          "boost_mode": "replace"
        }
      }
    }
  },
  "_source": [
    "quality",
    "CREATE",
    "UPDATE",
    "media_id",
    "data_type",
    "id_mdsum",
    "video_type",
    "title",
    "alias",
    "actors"
  ],
  "highlight": {
    "fields": {
      "title": {},
      "alias": {},
      "actors": {}
    }
  }
}
```

### Improved

```json
{
  "explain": false,
  "from": 0,
  "size": 50,
  "timeout": "800ms",
  "query": {
    "template": {
      "params": {
        "query": "Black Sails"
      },
      "inline": {
        "function_score": {
          "script_score": {
            "script": {
              "file": "score2",
              "params": {
                "t_normalize": 1,
                "t_weight": 1,
                "q_weight": 0,
                "f_weight": 0,
                "timestamp": 1480332107
              }
            }
          },
          "query": {
            "bool": {
              "should": [
                {
                  "multi_match": {
                    "query": "{{ query }}",
                    "fields": [
                      "title.shingles^3",
                      "title^2.5",
                      "alias.shingles^2",
                      "alias"
                    ],
                    "use_dis_max": true,
                    "type": "best_fields",
                    "tie_breaker": 0.3,
                    "operator": "or",
                    "boost": 1.5
                  }
                },
                {
                  "match": {
                    "actors": "{{ query }}"
                  }
                }
              ],
              "filter": {
                "bool": {
                  "must": [
                    {
                      "multi_match": {
                        "query": "{{query}}",
                        "fields": [ "title", "actors", "alias" ],
                        "minimum_should_match": "1<44%"
                      }
                    }
                  ]
                }
              }
            }
          },
          "boost_mode": "replace"
        }
      }
    }
  },
  "_source": [
    "quality",
    "CREATE",
    "UPDATE",
    "media_id",
    "data_type",
    "id_mdsum",
    "video_type",
    "title",
    "alias",
    "actors"
  ],
  "highlight": {
    "fields": {
      "title": {},
      "alias": {},
      "actors": {}
    }
  }
}
```

