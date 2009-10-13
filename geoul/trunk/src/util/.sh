#!/usr/bin/env bash
# .sh -- common script for geoul
# 
# Created: 2009-10-05
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2009, Geoul Project. (http://project.sparcs.org/geoul)

#set -u # we shouldn't use undefined variables

if [ -n "$GEOULDEBUG" ]; then
    # show stack
    n=`basename "$0"`
    case "$n" in
        main)
        n=$(basename "$(dirname "$(readlink -f "$0")")")
        n=${n%.d}
        ;;
    esac
    case "$PS4" in
        "+ ") PS4="+	$n> " ;;
        *) PS4="${PS4% }$n> " ;;
    esac
    export PS4
    set -x
fi

for-each-packages() {
    . "${GEOUL}for-each-packages" "$@"
}
