#!/bin/sh
# *BSD CVSup mirror init script for ftp.kaist.ac.kr
# Author: Jaeho Shin <netj@sparcs.kaist.ac.kr>
# Refined: 2006-04-16
# Created: 2004-06-05
# See http://motoyuki.bsdclub.org/BSD/cvsup.html

echo "WARNING: Never run this twice!! Or while already in service!!"
read -p "Proceed?"
[ "$REPLY" = y ] || exit 255

set -e
Base=`dirname "$0"`

## common
mkdir ~cvsupd                       # cvsupd home dir
chown root:root ~cvsupd
chmod 755 ~cvsupd

cd ~cvsupd

## FreeBSD
mkdir FreeBSD
pushd FreeBSD
mkdir prefixes
mkdir prefixes/FreeBSD.cvs                # CVS repository
mkdir prefixes/FreeBSD-gnats.current      # GNATS DB
mkdir prefixes/FreeBSD-mail.current       # mailing list archive
mkdir prefixes/FreeBSD-www.current        # www.FreeBSD.org data
mkdir prefixes/distrib.self               # CVSup config file
#mkdir prefixes/FreeBSD-jp.cvs             # JP CVS repository (for JP ONLY)
#mkdir prefixes/FreeBSD-jp-distrib.self    # CVSup config file (for JP ONLY)
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir scan
mkdir scan/cvs-all
mkdir scan/gnats
mkdir scan/www
mkdir scan/mail-archive
mkdir scan/distrib
#mkdir scan/jp-all                         # for JP ONLY
#mkdir scan/jp-distrib                     # for JP ONLY
chown mirror:mirror scan/*
chmod 755 scan/*
popd
ln -s FreeBSD/prefixes/distrib.self/sup sup-freebsd
#ln -s prefixes/jp-distrib.self/sup-jp sup-jp  # for JP ONLY


## NetBSD
mkdir NetBSD
pushd NetBSD
mkdir prefixes
mkdir prefixes/NetBSD.cvs
#mkdir prefixes/NetBSD-jp.cvs              # for JP ONLY
mkdir prefixes/NetBSD-distrib.self
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir scan
mkdir scan/netbsd
mkdir scan/netbsd-distrib
#mkdir scan/netbsd-jp-all                  # for JP ONLY
#mkdir scan/netbsd-jp-distrib              # for JP ONLY
chown mirror:mirror scan/*
chmod 755 scan/*
popd
ln -s NetBSD/prefixes/NetBSD-distrib.self/sup-netbsd sup-netbsd


## OpenBSD
mkdir OpenBSD
pushd OpenBSD
mkdir prefixes/OpenBSD.cvs
mkdir prefixes/OpenBSD-distrib.self
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir scan/OpenBSD-all
mkdir scan/OpenBSD-distrib
chown mirror:mirror scan/*
chmod 755 scan/*
popd
ln -s OpenBSD/prefixes/OpenBSD-distrib.self/sup-openbsd sup-openbsd


## central
mkdir prefixes                        # cvsupd collection (data) dir
mkdir scan                            # scan file dir
chown root:root prefixes scan
chmod 755 prefixes scan
cp $Base/update-prefixes+scan .
chmod 755 update-prefixes+scan
./update-prefixes+scan


## config files
cat >scan/distrib/refuse.self <<EOF
*.sh
cvsupd.access
cvsupd.passwd
prefixes
sup.client
supfile*
EOF
chmod 444 scan/distrib/refuse.self
ln scan/distrib/refuse.self scan/netbsd-distrib/refuse.self 
ln scan/distrib/refuse.self scan/OpenBSD-distrib/refuse.self 

ln -sf /mirror/etc/cvsupd.access cvsupd.access 
