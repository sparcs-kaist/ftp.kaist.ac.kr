#!/usr/bin/env bash
# .sh -- common script for geoul
# 
# Created: 2009-10-05
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2009, Geoul Project. (http://project.sparcs.org/geoul)

set -u # we shouldn't use undefined variables

[ -z "$GEOULDEBUG" ] || set -ex

for-each-packages() {
    . "${GEOUL}for-each-packages" "$@"
}
