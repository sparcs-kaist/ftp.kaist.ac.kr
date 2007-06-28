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
  $cmd now        use this to begin sync immediately
  $cmd pushed     use when upstream mirror is triggering push-mirroring
  $cmd regularly  check timestamp and begin sync if older than frequency
  $cmd stop       stop the synchronizing process

EOF
        [ $# -le 0 ] || echo "$cmd: $@"
    fi
    exit $exitcode
}
trap usage ERR
msg() { echo "$pkg: $@"; }
die() {
    local c=$1; shift
    echo "$pkg: $@"
    exit $c
}
err() { die "$@" >&2; }


## read package information
cd "$(dirname "$0")"
. /mirror/lib/pkg.sh


## choose what to do
triggered=$1
case "$triggered" in
    now|pushed) ;;
    regularly) [ -n "$frequency" ] || exit 6 ;;
    stop) ;;
    watch) ;;
    *) usage ;;
esac


## check environment
running_as_mirror_admin "$@"

shift
export GETARGS="$@"


## jobs to be/not to be done while sync_in_progress
if sync_in_progress; then
    case "$triggered" in
        stop)
        pgrp=`cat lock.owner 2>/dev/null`
        msg "terminating PGID $pgrp"
        [ -n "$pgrp" ] && childs=`ps --no-heading -o pid -$pgrp` &&
        [ -n "$childs" ] && kill "$@" $childs &>/dev/null &&
        msg "terminated PID" $childs && exit 0
        exit 2
        ;;

        watch)
        exec tail -f log
        ;;

        *) die 4 "another sync in progress" ;;
    esac
else
    case "$triggered" in
        now|pushed|regularly) ;;

        *) err 4 "no sync in progress" ;;
    esac
fi


## check timestamp if regular sync
compute_times # defines: timepast interval failures penalty delay remaining
if [ "$triggered" = regularly ]; then
    desc=
    if [ $penalty -gt 0 ]; then
        desc="=`humaninterval $interval`+`humaninterval $penalty`(${failures} failures)"
    fi
    if [ $timepast -lt $delay ]; then
        die 8 "not yet (age=`humaninterval $timepast` < `humaninterval $delay`$desc)"
    else
        msg "old enough (age = `humaninterval $timepast` >= `humaninterval $delay`$desc)"
    fi
fi


## lock this package
acquire_lock || exit 4


## prepare logging and unlocking
# clean up last failure report flag
rm -f failed.needsreport
# create a new log
log=/mirror/log/sync/`date +%Y/%m/%d/%T.%N`.$pkg.log
mkdir -p `dirname $log`
: >$log
ln -sf $log log
if [ -t 1 ]; then
    # monitor log if connected to a terminal
    tail -f $log &
    tailpid=$!
fi
# backup stdout/err fd's and redirect everything to log
exec 3>&1- 4>&2-  >>$log 2>&1

finish() {
    trap '' EXIT ERR INT HUP TERM
    set +e
    local result=
    if [ $exitcode -eq 0 ]; then
        # record success
        result=success
        touch timestamp
        clear_failures
    else
        # record failure
        result=failure
        increase_failures
    fi
    msg "sync $result at `humandate`"
    # stop monitoring log
    if [ -n "$tailpid" ]; then
        sleep 1
        kill $tailpid 2>/dev/null
        wait $tailpid
    fi
    # restore stdout/err
    exec >&3- 2>&4-
    # save log
    #  compress log
    gzip -f $log
    ln -sf $log.gz .$result.log.gz
    rm -f log
    #  mark success/failure
    case "$result" in
        failure)
        # raise need-to-report flag
        touch failed.needsreport
        ;;
        success)
        ;;
    esac
    #  record to RSS
    record-news.feed sync-$result $log.gz
    release_lock
    exit $exitcode
}
trap 'exitcode=$?; set +x; finish' EXIT ERR
trap 'exit 2' INT HUP TERM

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
