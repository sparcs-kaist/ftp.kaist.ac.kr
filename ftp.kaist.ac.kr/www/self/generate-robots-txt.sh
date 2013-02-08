#!/usr/bin/env bash
# generate-robots-txt.sh -- Generate a defensive enough robots.txt for our website
# 
# Created: 2013-02-08
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2013, Geoul Project. (http://ftp.kaist.ac.kr/geoul)
set -eu

# First, robots.txt header
cat <<HEAD
User-Agent: *
Disallow: /pub/
Disallow: /geoul/usage/reports/webalizer/
HEAD

# Then, disallow any non-original pkg that exposes its data thru /mirror/ftp/
/mirror/bin/foreachpkg sh -c '[ -e original ] || readlink -f data' |
grep '^/mirror/ftp/' | sed 's#^/mirror/ftp#Disallow: #; s#$#/#'

