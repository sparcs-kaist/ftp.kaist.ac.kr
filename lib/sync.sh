#!/usr/bin/env bash
# sync.sh -- Common pieces of synchronizing scripts
# 
# Created: 2006-01-22
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006, Geoul Project. (http://ftp.kaist.ac.kr/geoul)


## printers
usage() {
    local exitcode=$?
    [ $exitcode -eq 0 ] && exitcode=2
    local cmd=`basename "$0"`
    if [ -t 1 ]; then
        cat <<EOF
Geoul synchronizer for $pkg
Usage:
  $cmd now        synchronizes immediately
  $cmd regularly  checks timestamp and runs '$cmd now' if older than frequency

EOF
        [ $# -le 0 ] || echo "$cmd: $@"
    fi
    exit $exitcode
}
trap usage ERR
msg() { echo "$pkg: $@"; }
err() {
    local c=$1; shift
    echo "$pkg: $@" >&2
    exit $c
}


## read package information
cd "$(dirname "$0")"
. /mirror/lib/pkg.sh


## choose what to do
triggered=$1
case "$triggered" in
    now) ;;
    regularly) [ -n "$frequency" ] || exit 6 ;;
    *) usage ;;
esac


## check environment
running_as_mirror_admin "$@"


## check timestamp if regular sync
if sync_in_progress; then
    msg "another sync in progress"
    exit 4
fi

compute_times # defines: timepast interval failures penalty delay remaining
if [ "$triggered" = regularly ]; then
    desc=
    if [ $penalty -gt 0 ]; then
        desc="=`humaninterval $interval`+`humaninterval $penalty`(${failures} failures)"
    fi
    if [ $timepast -lt $delay ]; then
        msg "not yet (age=`humaninterval $timepast` < `humaninterval $delay`$desc)"
        exit 8
    else
        msg "old enough (age = `humaninterval $timepast` >= `humaninterval $delay`$desc)"
    fi
fi


## lock this package
acquire_lock || exit 4


## prepare logging and unlocking
# take care of old logs
if [ -f log ]; then
    ln -f log fail.log
    savelog -q fail.log
    mv -f log fail.log
fi
# and create a new one
: >log
if [ -t 1 ]; then
    # monitor log if connected to a terminal
    tail -f log &
    tailpid=$!
fi
exec >>log 2>&1

finish() {
    trap '' EXIT ERR INT HUP TERM
    local result=
    if [ $exitcode -eq 0 ]; then
        # record success
        result=done
        touch timestamp
        clear_failures
    else
        # record failure
        result=failed
        increase_failures
    fi
    msg "sync $result at `humandate`"
    # stop monitoring log
    if [ -n "$tailpid" ]; then
        sleep 1
        kill $tailpid
        wait $tailpid
    fi
    # save log
    #  remove previous unreported failure log
    rm -f fail.log
    #  distinguish success/failure logs
    if [ "$result" = failed ]; then
        #  rotate and place fail.log so it gets reported
        ln -f log fail.log
        savelog -q fail.log
        mv -f log fail.log
    else
        savelog -q log
    fi
    release_lock
    exit $exitcode
}
trap 'exitcode=$?; set +x; finish' EXIT ERR
trap '' INT HUP TERM

## now, the real synchronization begins
msg "sync begins at `humandate`"
cat <<EOF
+ triggered=$triggered
+ source=$source
+ frequency=$frequency
+ timepast=`humaninterval $timepast`
+ failures=$failures
EOF
set +e -x
