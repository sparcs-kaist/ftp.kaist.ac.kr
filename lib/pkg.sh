#!/usr/bin/env bash
# pkg.sh -- Common pieces for handling a package
# 
# Created: 2006-04-07
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)
set -e

LockValidDays=10 #days

. /mirror/lib/geoul.sh

if ! type usage >/dev/null 2>&1; then
    usage() {
        ! [ -t 1 ] || echo "`basename "$0"`: $@"
        exit 2
    }
fi

in_a_package() {
    # must be in a pkg directory
    case "$PWD" in
        /mirror/pkgs/*) true ;;
        *) usage "$PWD: not inside a package"; false ;;
    esac
    # grab its id
    pkg=`basename "$PWD"`
    # name (optional; defaults to $pkg)
    [ -f name ] && name=`cat name` || name=$pkg
    # actual path for data
    datapath=`readlink data || echo $PWD/data`
    if [ -f source ]; then
        # source
        source=`cat source`
        # frequency (optional)
        ! [ -f frequency ] || frequency=`cat frequency`
        # valid period (optional; defaults to 1d)
        [ -f validfor ] && validfor=`cat validfor` || validfor=1d
    elif [ -f original ]; then
        # original, no source, frequency, nor valid period
        true
    else
        usage "$pkg: no source defined and not original"
        false
    fi
    # color (for graphs)
    if [ -f color ]; then
        color=`cat color`
    else
        color=`echo $pkg | md5sum`
        color="${color:0:6}"
    fi
}

mtime() {
    local f=$1
    # XXX: works on GNU only :-|
    local t=`date -r "$f" +%s 2>/dev/null || echo 0`
    echo ${t:-0}
}
compute_times() {
    lasttime=`mtime timestamp`
    timepast=$((`now` - $lasttime))
    [ -n "$frequency" ] && interval=`secondsof $frequency` || interval=
    [ -n "$validfor" ] && validsecs=`secondsof $validfor` || validsecs=
    failures=`number_of_failures`
    penalty=`penalty_for $failures`
    delay=$(( $interval + $penalty ))
    remaining=$(( $delay - $timepast ))
}

# failures
number_of_failures() {
    local num=`cat failed 2>/dev/null`
    echo "${num:-0}"
}
clear_failures() {
    rm -f failed
}
increase_failures() {
    local failures=`number_of_failures`
    # TODO: use lower bound?
    echo $(($failures + 1)) >failed
}
penalty_for() {
    # penalty according to failures
    # 600s * failures^2 = ( 0min, 10min, 4*10min, 9*10min, 16*10min, ... )
    local failures=${1:-`number_of_failures`}
    echo $(( 100 * $failures * ($failures+1) * (2*$failures+1) ))
    # this must return sum of all delays until current amount of failures
    # i.e. sum(600 * x^2) = 600 * 1/6*x*(x+1)*(2*x+1)
}

# lock
needs_lock() { [ -z "$lock" ] || return 0
    # figure out where's the lock, and set $lock
    if [ -L lock ]; then
        lock=`readlink lock`
    else
        lock=lock
    fi
}

lock_expired() { needs_lock
    # detect stale (too old) lock files
    [ -z "`find "$lock" -mtime -$LockValidDays 2>/dev/null`" ]
}
sync_in_progress() { needs_lock
    [ -e "$lock" -a -e log ]
    # TODO: is the owner process still alive?
}

acquire_lock() { needs_lock
    if sync_in_progress && lock_expired; then kill_lock; fi
    # using lockfile(1) included in procmail(1)
    lockfile -r3 "$lock"
    # record owner info
    echo $$ >lock.owner
}
release_lock() { needs_lock
    rm -f lock.owner lock.reported "$lock"
}
kill_lock() {
    # kill the lock owner and release it
    local owner=`cat lock.owner 2>/dev/null`
    [ -z "$owner" ] || kill -KILL $owner
    release_lock
}

in_a_package
