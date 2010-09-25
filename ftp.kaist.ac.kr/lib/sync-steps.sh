#!/usr/bin/env bash
# sync-steps.sh -- an ad-hoc split-up of steps for synchronizing a package
# You must source pkg.sh to properly use steps defined in this script.
# 
# Created: 2010-09-09
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2010, Geoul Project. (http://ftp.kaist.ac.kr/geoul)

prepare-sync() {
    ## prepare logging and unlocking
    # clean up last failure report flag
    rm -f failed.needsreport
    # create a new log
    log=/mirror/log/sync/`date +%Y/%m/%d/%T.%N`.$pkg.log
    mkdir -p `dirname $log`
    : >$log
    ln -sf $log log 2>/dev/null
    ## now, the real synchronization begins
    {
    echo "$pkg: sync begins at `humandate`"
    cat <<-EOF
	+ source=$source
	+ site=$SITENAME
	+ node=$HOSTNAME
	+ triggered=$triggered
	+ frequency=$frequency
	+ timepast=`humaninterval $timepast`
	+ failures=$failures
	EOF
    } >>$log
}

finish-sync() {
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
    echo "$pkg: sync $result at `humandate`" >>$log
    # save log
    #  compress log
    gzip -f $log
    ln -sf $log.gz .$result.log.gz 2>/dev/null
    rm -f log log.*
    #  mark success/failure
    case "$result" in
        failure)
        # raise need-to-report flag
        touch failed.needsreport
        # TODO: check sources, switch sources
        ;;
        success)
        ;;
    esac
    #  record to RSS
    record-news.feed sync-$result $log.gz
    #  TODO record-sync-cost using `collect-sync-cost $log.gz`
}

