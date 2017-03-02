---
title: Relevance Beyond Text
---

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

## Points

Text-based ranking measures are ncessary but not sufficient for high quality retrieval.
Extremely important to confirm intuition with experiments.

* Prefer multiplicative boosting to additive boosting
* Apply a boost function based on some static document attribute
* DocumentRank (e.g. quality, length, etc.) like PageRank

<!--more-->

## Table of Contents

* TOC
{:toc}

## Time Boost

基本上信息都会随着时间衰减。但是对于不同类型的信息，其衰减速度又是不同的。

可以通过综合freshness/recency来提高搜索结果相关性

* freshness boost (boost > 1.0)
* penalty (boost < 1.0)
* mixed

reciprocal function:

recip(x, m, a, b) = a / (m\*x + b)

* when a = b and x > 0
    * 数从最大值 1 开始递减
    * 函数具有半衰期 a
* 同时增大 a 和 b 的值可以使曲线递减变缓
* 可以使用 recip(exp(round(log(x))), m, a, b) 来使得函数具有类似分段效果
* 如果分段数目较少，可以使用 range filter boost
* when a > b and x > 0
    * 最大值大于 1，可以在某个为1的点左右 boost 差异更为明显
* 可以使用 min(recip(x), 0.20) 设置下限
* recip(abs(x)) 可以对于未来时间一同 boost

![recip](/assets/time-boost-recip.svg)

## Content Length Boost

maxBoost - recip(x, m, a, b)

* m 控制了曲线上升快慢

![recip](/assets/content-length-boost-recip.svg)

## Popularity Boost

$$score = \_score \cdot log(mx + b)$$

* b=1 可以避免将 popularity 为 0 的条目分数变为 0
* b>1 可以使得曲线开始部分变平滑
* m 越小，曲线越平滑

$$score = \_score + log(mx + b)$$

* 可以减小 popularity 的影响

$$score = (mx + b)^n$$

* n 可以控制增长速度
* b 可以使开始变平滑
* m 可以控制增长速度

$$1 + (0.4 \times recent + 0.3 \times lastWeek + 0.2 \times lastMonth + 0.1 \times past)$$

* 其中每个时期变化可能不同，如果选取的时间范围太小可能导致某些时段对于某些视频具有偏好性质的boost提升

## Newton's Law of Cooling

## Implementation

### Solr

#### Additive Boost

* bf
: boost function
* bq
: boost query

## References

* [https://www.elastic.co/guide/en/elasticsearch/guide/current/boosting-by-popularity.html](https://www.elastic.co/guide/en/elasticsearch/guide/current/boosting-by-popularity.html)
* [https://nolanlawson.com/2012/06/02/comparing-boost-methods-in-solr/](https://nolanlawson.com/2012/06/02/comparing-boost-methods-in-solr/)
* [https://www.safaribooksonline.com/blog/2014/11/04/implementing-popularity-boosting-in-search/](https://www.safaribooksonline.com/blog/2014/11/04/implementing-popularity-boosting-in-search/)
* [http://www.evanmiller.org/rank-hotness-with-newtons-law-of-cooling.html](http://www.evanmiller.org/rank-hotness-with-newtons-law-of-cooling.html)
