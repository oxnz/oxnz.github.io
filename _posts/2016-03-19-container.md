---
title: Container
categories: [sysadm]
tags: [container, cgroups]
---

## Introduction

Container related tech stuff

<!--more-->

## Table of Contents

* TOC
{:toc}

## Container Architecture

![Container Architecture](/assets/container-arch.png)

## Docker

Docker combines lightweight application isolation with an application-centric packaging model and the flexibility of an image-based deployment method to enable portability across bare metal systems, virtual machines and private and public clouds.

## Container Manager

* Kubernetes

## Kubernetes

The goal of Kubernetes is to enable users to easily manage, monitor and control containerized application deployments across a large cluster of container hosts.

### Architecture

![Kubernetes Architecture](/assets/kubernetes-arch.png)

### Setup

kubernetes:

* Master: kubectl (deploy to Node)
* Node: runtime environment for container

KUBERNETES CLUSTER

* docker.service
* kubelet.service

containerized kubernetes service

containerized kubernetes cluster

```
          |- docker  |
master   ->  flannel -> service to run
  |       |- kubelet |
  |
  |-- Node
  |-- Node
  |-- ...
```

all system need have their time synced.

* install docker
* disable firewall
* prepare dock container
* containers
	* node1
	* node2
* docker export myweb > web.tar
* docker import - web.tar
* setup kubernetes
* start up master
* start up nodes

master and nodes

* master
	* systemd
		* docker
		* etcd
		* flannel
* container
	* pod as service
		* kube-apiserver
		* kube-controller-manager
		* kube-scheduler

yum install kubernetes-master flannel etcd

/etc/kubernetes/manifests

* apiserver-pod.json
	* name:kube-apiserver
	* spec:containers:port:8080
	* hostNetwork: true
	* volumnes
		* name:etcssl
		* hostPath: path: /etc/ssl
		* name: config
		* hostPath: path: /etc/kubernets
* controller-mgr-pod.json
	* name:kube-controller-manager
* scheduler-pod.json
	* name:kube-scheduler
	* volumnes
		* name:config
		* hostPath:path: /etc/kubernetes

Liveness Probe

* httpGet
	* path: /healthz
	* port: 8080
* initialDelaySeconds: 15
* timeout Seconds: 15

## Namespace

namespace provides a way of process isolation

* Mount namespace
	* different processes group see different file system hierarchy
* UTS namespace
	* isolate two system identifier
* IPC namespace
	* isolate certain interprocess communication resources
* PID namespace
	* /proc
* Network namespace
* User namespace

## cgroup

cgroup - systemd -{

* slice
* scope
* service units

## References

* [Virtualization with Linux Containers](https://www.suse.com/documentation/sles11/singlehtml/lxc_quickstart/lxc_quickstart.html)
* [Getting Started with Containers](https://access.redhat.com/documentation/en/red-hat-enterprise-linux-atomic-host/7/getting-started-with-containers/getting-started-with-containers)
