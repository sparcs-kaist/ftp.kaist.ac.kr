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
HTTPRootURL=http://$SITENAME/
BaseURL=http://$SITENAME/geoul
PkgsRootURL=$BaseURL/pkgs
SyncLogRootURL=$BaseURL/sync
StatusURL=http://geoulmon.appspot.com/sites/$SITENAME

# environment
LC_ALL=C
LANG=C
LANGUAGE=C
PATH="/mirror/bin:$PATH"

