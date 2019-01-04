---
layout: post
title: Zookeeper
---

>
Apache ZooKeeper, a distributed coordination service for distributed systems.
By providing a robust implementation of a few basic operations, ZooKeeper simplifies the implementation of many advanced patterns in distributed systems.

## Table of Contents

* TOC
{:toc}

## As a Distributed File System

* zNode
	* ephemeral zNodes
		* that will disappear when the session of its owner ends
		* typical use case is when using ZooKeeper for discovery of hosts in distributed system. Each server can then publish its IP address in an ephemeral node. If a server loose connectivity with ZooKeeper and fail to reconnect within the session timeout, its information is deleted
	* sequential zNodes
		* whose names are automatically assigned a sequence number suffix. this suffix is strictly growing and assigned by ZooKeeper when the zNode is created
		* An easy way of doing leader election with ZooKeeper is to let every server publish its information in a zNode that is both sequential and ephemeral. Then, whichever server has the lowest sequential zNode is the leader. If the leader or any other server for that matter, goes offline, its session dies and its ephemeral node is removed, and all other servers can observe who is the new leader.

## As a Message Queue

registering watchers on zNodes. This allows clients to be notified of the next update to that zNode.

ZooKeeper gives guarantees about ordering. Every update is part of a total ordering. All clients might not be at the exact same point in time, but they will all see every update in the same order.

## The CAP Theorem

**Consistency**, **Availability** and **Partition** tolerance are the the three properties considered in the CAP theorem.
The theorem states that a distributed system can only provide **two** of these three properties.
ZooKeeper is a **CP** system with regard to the CAP theorem.
This implies that it sacrifices availabilty in order to achieve consistency and partition tolerance. In other words, if it cannot guarantee correct behaviour it will not respond to queries.

## Consistency Algorithm

Zab like Paxos

## References

* [https://www.elastic.co/blog/found-zookeeper-king-of-coordination#operations-yet-another-system-to-manage](https://www.elastic.co/blog/found-zookeeper-king-of-coordination#operations-yet-another-system-to-manage)
