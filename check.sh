#!/usr/bin/env sh
# 
# ===============================================================
#
# Filename:	check.sh
#
# Author:		Oxnz
# Email:		yunxinyi@gmail.com
# Created:		2016-05-14 21:31:15 CST
# Last-update:	2016-05-14 21:31:15 CST
# Description: ANCHOR
#
# Version:		0.0.1
# Revision:	[None]
# Revision history:	[None]
# Date Author Remarks:	[None]
#
# License:
# Copyright (c) 2016 Oxnz
#
# Distributed under terms of the [LICENSE] license.
# [license]
#
# ===============================================================
#

for f in ./_posts/*; do
	if ! grep 'layout: post' "$f" > /dev/null 2>&1; then
		echo "$f"
	fi
done
