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
    regularly)
    [ -n "$frequency" ] || exit 6
    system_not_degraded
    ;;
    stop) ;;
    watch) ;;
    *) usage ;;
esac


## check environment
running_as_mirror_admin "$@"
running_as_process_group_leader "$@"

shift
export GETARGS="$@"


## stop
if [ "$triggered" = stop ]; then
    if sync_in_progress; then
        kill_lock_owner
        die 0 "stopped running sync"
    else
        ruins=`find lock lock.* log log.* 2>/dev/null || true`
        if [ -n "$ruins" ]; then
            # TODO: clean up (as in finish)
            rm -f log log.*
            release_lock
            die 0 "cleaned up dead sync"
        else
            die 4 "no sync in progress"
        fi
    fi
fi


## jobs to be/not to be done while sync_in_progress
if sync_in_progress; then
    case "$triggered" in
        watch)
        exec tail -f log
        ;;

        *)
        ${SyncReentrant:-false} || 
        die 4 "another sync in progress"
        ;;
    esac
fi

case "$triggered" in
    now|pushed|regularly) ;;

    *) err 4 "no sync in progress" ;;
esac


## check timestamp if regular sync
compute_times # defines: timepast interval failures delay remaining
if [ "$triggered" = regularly ]; then
    if [ $timepast -lt $delay ]; then
        die 8 "not yet (age=`humaninterval $timepast` < `humaninterval $delay`)"
    else
        msg "old enough (age = `humaninterval $timepast` >= `humaninterval $delay`)"
    fi
fi


## lock this package
${SyncReentrant:-false} ||
acquire_lock || die 4 "locked or another sync in progress"

. /mirror/lib/sync-steps.sh

before-sync() {
    trap 'exitcode=$?; set +x; after-sync' EXIT ERR
    trap 'exit 2' INT HUP TERM
    prepare-sync
    if [ -t 1 ]; then
        # monitor log if connected to a terminal
        tail -f $log &
        tailpid=$!
    fi
    # backup stdout/err fd's and redirect everything to log
    exec 3>&1- 4>&2-  >>$log 2>&1
    # show all commands being run
    set +e -x
}

after-sync() {
    # restore stdout/err
    exec >&3- 2>&4-
    trap '' EXIT ERR INT HUP TERM
    finish-sync
    # stop monitoring log
    if [ -n "$tailpid" ]; then
        sleep 1
        kill $tailpid 2>/dev/null
        wait $tailpid
    fi
    ${SyncReentrant:-false} ||
    release_lock
    exit $exitcode
}


${SyncCustom:-false} ||
before-sync
