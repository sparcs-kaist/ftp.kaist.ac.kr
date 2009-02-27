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
HTTPRootURL=$BaseURL/

# environment
LC_ALL=C
LANG=C
LANGUAGE=C
PATH="/mirror/bin:$PATH"

# iterator
foreachpkg() {
    . /mirror/bin/foreachpkg
}

realpath_to_self() {
    readlink -f "$0" || { cd "$OLDPWD" && readlink -f "$0"; }
}

# switch running user to mirror admin
running_as_mirror_admin() {
    [ x"`whoami`" = x"$MirrorAdmin" ] || exec sudo -H -u "$MirrorAdmin" "`realpath_to_self`" "$@"
}

running_as_process_group_leader() {
    [ x"`ps -o pgid= -p $$`" == x"$$" ] || exec setsid "`realpath_to_self`" "$@"
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

# convert XML Schema duration format to number of seconds
secondsof() {
    local duration=$1; shift
    duration-error() {
        echo "$duration:invalid duration format" >&2
        false
    }
    local dpos=true
    [ x"${duration#-}" = x"$duration" ] || dpos=false
    local ddt=${duration#P}
    [ x"$ddt" != x"$duration" ] || duration-error
    local dd=${ddt%%T*}
    local dt=${ddt#$dd}
    dt=${dt#T}
    [ -z "$dt" -o x"$dt" != x"${ddt#$dd}" ] || duration-error
    local ddexpr=$dd
    ddexpr=${ddexpr//Y/*31557600 }
    ddexpr=${ddexpr//M/*2629800 }
    ddexpr=${ddexpr//D/*86400 }
    local dtexpr=$dt
    dtexpr=${dtexpr//H/*3600 }
    dtexpr=${dtexpr//M/*60 }
    dtexpr=${dtexpr//S/ }
    local s=0
    for e in $ddexpr $dtexpr
    do let s+=$e || duration-error
    done
    $dpos || s=-$s
    echo $s
}

# convert number of seconds to XML Schema duration format
humaninterval() {
    local interval=${1:-0}
    local dsgn= dd= dt=
    if [ $interval = 0 ]; then
        dt=0S
    else
        if [ $interval -lt 0 ]; then
            dsgn=-
            interval=-$interval
        fi
        local H=$(( $interval / 3600 ))
        local D=$(( $H / 24 )); H=$(( $H % 24 ))
        local M=$(( $interval % 3600 / 60 ))
        local S=$(( $interval % 3600 % 60 ))
        [ $D = 0 ] || dd="$dd${D}D"
        [ $H = 0 ] || dt="$dt${H}H"
        [ $M = 0 ] || dt="$dt${M}M"
        [ $S = 0 ] || dt="$dt${S}S"
    fi
    echo "${sgn}P${dd}${dt:+T$dt}"
}


log_uri() {
    local log=$1
    ! [ -L "$log" ] || log=`readlink "$log"`
    log=${log#/mirror/log/sync/}
    echo "$SyncLogRootURL/$log"
}

pkg_uri() {
    local pkg=$1
    echo "$BaseURL/pkgs/$pkg"
}

