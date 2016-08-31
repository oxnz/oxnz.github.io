---
layout: post
title: NVIDIA CUDA for Linux 起步
date: 2012-12-04 16:42:43.000000000 +08:00
type: post
published: true
status: publish
categories:
- CUDA
tags:
- nvidia
meta:
  _edit_last: '1'
---
<p>NVIDIA CUDA for Linux 起步<br />
系统需求:</p>
<ul>
<li>CUDA兼容GPU</li>
<li>支持的Linux系统和gcc编译器及工具链</li>
<li>NVIDIA CUDA 工具集<a href="http://www.nvidia.com/content/cuda/cuda-downloads.html">http://www.nvidia.com/content/cuda/cuda-downloads.html</a></li>
</ul>
<p>安装CUDA 开发工具</p>
<ul>
<ul>
<li>检查系统具有CUDA兼容的GPU</li>
</ul>
</ul>
<p><code>lspci | grep -i nvidia(update-pciids)</code><br />
如果你的显卡在这个列表上:<a href="http://www.nvidia.com/object/cuda_gpus.html">http://www.nvidia.com/object/cuda_gpus.html</a>，那么你的GPU就是CUDA兼容的。</p>
<ul>
<li>检查系统具有支持的Linux版本</li>
<li>检查系统安装了gcc</li>
<li>下载NVIDIA CUDA Toolkit</li>
<li>安装NVIDIA CUDA Toolkit</li>
<li>测试安装的软件运行正常并且可以与硬件通讯</li>
</ul>
