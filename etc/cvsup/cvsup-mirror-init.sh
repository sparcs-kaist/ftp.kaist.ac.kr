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

## common
mkdir $home_cvsupd                       # cvsupd home dir
chown root:root $home_cvsupd
chmod 755 $home_cvsupd

cd $home_cvsupd
mkdir prefixes                        # cvsupd collection (data) dir
mkdir sup                            # sup file dir
chown root:root prefixes sup
chmod 755 prefixes sup


## FreeBSD
mkdir prefixes/FreeBSD.cvs                # CVS repository
mkdir prefixes/FreeBSD-gnats.current      # GNATS DB
mkdir prefixes/FreeBSD-mail.current       # mailing list archive
mkdir prefixes/FreeBSD-www.current        # www.FreeBSD.org data
mkdir prefixes/distrib.self               # CVSup config file
#mkdir prefixes/FreeBSD-jp.cvs             # JP CVS repository (for JP ONLY)
#mkdir prefixes/FreeBSD-jp-distrib.self    # CVSup config file (for JP ONLY)
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir sup/cvs-all
mkdir sup/gnats
mkdir sup/www
mkdir sup/mail-archive
mkdir sup/distrib
#mkdir sup/jp-all                         # for JP ONLY
#mkdir sup/jp-distrib                     # for JP ONLY
chown mirror:mirror sup/*
chmod 755 sup/*
ln -s prefixes/distrib.self/sup sup-freebsd
#ln -s prefixes/jp-distrib.self/sup-jp sup-jp  # for JP ONLY


## NetBSD
mkdir prefixes/NetBSD.cvs
#mkdir prefixes/NetBSD-jp.cvs              # for JP ONLY
mkdir prefixes/NetBSD-distrib.self
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir sup/netbsd
mkdir sup/netbsd-distrib
#mkdir sup/netbsd-jp-all                  # for JP ONLY
#mkdir sup/netbsd-jp-distrib              # for JP ONLY
chown mirror:mirror sup/*
chmod 755 sup/*
ln -s prefixes/NetBSD-distrib.self/sup-netbsd sup-netbsd

## OpenBSD
mkdir prefixes/OpenBSD.cvs
mkdir prefixes/OpenBSD-distrib.self
chown mirror:mirror prefixes/*
chmod 755 prefixes/*
mkdir sup/OpenBSD-all
mkdir sup/OpenBSD-distrib
chown mirror:mirror sup/*
chmod 755 sup/*
ln -s prefixes/OpenBSD-distrib.self/sup-openbsd sup-openbsd


## config files
cat >sup/distrib/refuse.self <<EOF
*.sh
cvsupd.access
cvsupd.passwd
prefixes
sup.client
supfile*
EOF
chmod 444 sup/distrib/refuse.self
ln sup/distrib/refuse.self sup/netbsd-distrib/refuse.self 
ln sup/distrib/refuse.self sup/OpenBSD-distrib/refuse.self 

ln -sf /mirror/etc/cvsupd.access cvsupd.access 
