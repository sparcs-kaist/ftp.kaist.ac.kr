#!/usr/bin/env bash
# geoul.sh -- Common pieces
# 
# Created: 2006-04-07
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)

# named constants
export SITENAME=ftp.kaist.ac.kr
MirrorAdmin=mirror
FTPRootPath=/mirror/ftp/
FTPRootURL=ftp://$SITENAME/
BaseURL=http://$SITENAME
StatusURL=$BaseURL/status
PkgsRootURL=$BaseURL/pkgs
SyncLogRootURL=$BaseURL/sync
HTTPRootURL=$BaseURL/pub/

# environment
LC_ALL=C
LANG=C
LANGUAGE=C
PATH="/mirror/bin:$PATH"

# iterator
foreachpkg() {
    . /mirror/bin/foreachpkg
}

# switch running user to mirror admin
running_as_mirror_admin() {
    local self=`readlink -f "$0" || { cd "$OLDPWD" && readlink -f "$0"; }`
    [ `whoami` = $MirrorAdmin ] || exec sudo -H -u $MirrorAdmin "$self" "$@"
}

# check nosync
system_not_degraded() {
    if [ -e /mirror/etc/noupdate ]; then
        if [ -t 1 ]; then
            echo "/mirror/etc/noupdate: system in degraded mode"
        fi
        exit 36
    else
        true
    fi
}

# for readability
now() {
    date "$@" +%s
}
mtime() {
    local f=$1
    # XXX: works on GNU only :-|
    local t=`date -r "$f" +%s 2>/dev/null || echo 0`
    echo ${t:-0}
}

# ISO8601:2000 date format
isodate() {
    local zone=`date "$@" +%z`
    local hr=${zone%??}
    local zone=$hr:${zone#$hr}
    [ "$zone" = "+00:00" ] && zone=Z
    date "$@" +%FT%T$zone
}

# human friendly date
humandate() {
    date "$@" +'%Y-%m-%d %H:%M:%S %z'
}

# convert interval specifier to seconds
secondsof() {
    local period=$1; shift
    local scale=
    case $period in
        daily)  period=1d ;;
        hourly) period=1h ;;
        weekly) period=1w ;;
    esac
    case $period in
        *w) scale=$((86400 * 7)) ;;
        *d) scale=86400 ;;
        *h) scale=3600 ;;
        *M|*"'") scale=60 ;;
        *s|*'"') scale=1 ;;
        *[0-9]) scale=1; period=${period}x ;;
    esac
    if [ -n "$scale" ]; then
        echo $((${period%?} * $scale))
    else
        echo "unknown period: $period" >&2
        false
    fi
}

# convert seconds to human friendly interval
humaninterval() {
    local interval=${1:-0}
    if [ $interval = 0 ]; then
        echo '0"'
    else
        if [ $interval -lt 0 ]; then
            printf '-'
            interval=-$interval
        fi
        local H=$(( $interval / 3600 ))
        local d=$(( $H / 24 )); H=$(( $H % 24 ))
        local w=$(( $d / 7 ));  d=$(( $d % 7 ))
        local M=$(( $interval % 3600 / 60 ))
        local S=$(( $interval % 3600 % 60 ))
        [ $w = 0 ] || printf '%dw' $w
        [ $d = 0 ] || printf '%dd' $d
        [ $H = 0 ] || printf '%dh' $H
        [ $M = 0 ] || printf '%d'\' $M
        [ $S = 0 ] || printf '%d'\" $S
        echo
    fi
}


log_uri() {
    local log=$1
    ! [ -L "$log" ] || log=`readlink "$log"`
    log=${log%.gz}
    log=${log#/mirror/log/sync/}
    echo "$SyncLogRootURL/$log"
}

pkg_uri() {
    local pkg=$1
    echo "$BaseURL/pkgs/$pkg"
}

excerpt() {
    local f=$1 l=${2:-10}
    if [ `zless "$f" 2>/dev/null | wc -l || echo 0` -gt $(($l * 2)) ]; then
        zless "$f" | head -$l
        echo "..."
        zless "$f" | tail -$l
    else
        zless "$f"
    fi
}
