#!/usr/bin/env bash
# pkg.sh -- Common pieces for handling a package
# 
# Created: 2006-04-07
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)
set -e

LockValidDays=7 #days

. /mirror/lib/geoul.sh

if ! type usage >/dev/null 2>&1; then
    usage() {
        ! [ -t 1 ] || echo "`basename "$0"`: $@"
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
    # check visibility
    visible=true
    if [ -e HIDDEN ]; then
        visible=false
    fi
    # color (for graphs)
    if [ -f color ]; then
        color=`cat color`
    else
        color=`echo $pkg | md5sum`
        color="${color:0:6}"
    fi
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

lock_owner() {
    local owner=`cat lock.owner 2>/dev/null`
    if [ -n "$owner" ]; then
        echo owner=$owner
        echo host=${owner%:*}
        echo pgrp=${owner#*:}
    fi
}
lock_expired() { needs_lock
    # detect stale (too old) lock files
    [ -z "`find "$lock" -mtime -$LockValidDays 2>/dev/null`" ]
}
sync_in_progress() { needs_lock
    # lock exists
    if [ -e "$lock" ]; then
        # the owner process is still alive
        local owner host pgrp
        eval `lock_owner`
        local rsh=
        [ -z "$host" -o "$host" = "$HOSTNAME" ] || rsh="ssh $host"
        $rsh ps -p $pgrp &>/dev/null
    else
        false
    fi
}

acquire_lock() { needs_lock
    # remove expired, stale lock
    if ! sync_in_progress; then release_lock; fi
    if lock_expired; then kill_lock_owner; release_lock; fi
    # use lockfile(1) included in procmail(1)
    if lockfile -r3 "$lock" 2>/dev/null; then
        # record owner info
        echo $HOSTNAME:$$ >lock.owner
    else
        false
    fi
}
release_lock() { needs_lock
    rm -f lock.owner lock.reported "$lock"
}
kill_lock_owner() {
    # kill the lock owner and release it
    local owner host pgrp
    eval `lock_owner`
    if [ -n "$owner" ]; then
        # send TERM
        if sync_in_progress; then
            ssh $host kill -TERM -$pgrp
            sleep 2
        fi
        # send KILL if still alive
        while sync_in_progress; do
            ssh $host kill -KILL -$pgrp
            sleep 2
        done
    fi
}

in_a_package
