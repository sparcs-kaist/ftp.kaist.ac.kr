# Makefile for Geoul/ftp.kaist.ac.kr configuration
# 
# Created: 2008-05-18
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2008, Geoul Project. (http://ftp.kaist.ac.kr/geoul)

## Required packages
PACKAGES+=\
bash                                                                          \
coreutils                                                                     \
sed                                                                           \
grep                                                                          \
findutils                                                                     \
debianutils                                                                   \
gzip                                                                          \
procmail                                                                      \
perl                                                                          \
libxml2-utils                                                                 \
xsltproc                                                                      \
rsync                                                                         \
lftp                                                                          \
jigdo-file                                                                    \
cron                                                                          \
ntpdate                                                                       \
logrotate                                                                     \
logcheck                                                                      \
openssh-client openssh-server                                                 \
pidentd                                                                       \
vsftpd                                                                        \
lighttpd                                                                      \
rrdtool                                                                       \
webalizer                                                                     \
awstats                                                                       \
acl                                                                           \
screen                                                                        \
bc                                                                            \
#

## configs for normal nodes
CONFIGS+=\
/etc/cron.d/geoul                                                             \
/etc/sudoers.d/geoul                                                          \
/etc/sysctl.conf                                                              \
/etc/aliases                                                                  \
/etc/admin-contact                                                            \
/etc/vsftpd.conf                                                              \
/var/log/geoul/ftpd/                                                          \
/var/log/geoul/httpd/                                                         \
/var/log/geoul/rsyncd/                                                        \
/var/log/geoul/measure-usage/                                                 \
perms                                                                         \
/etc/lighttpd/lighttpd.conf                                                   \
/etc/rsyncd.conf                                                              \
/etc/logrotate.d/geoul                                                        \
/etc/webalizer/webalizer.conf                                                 \
/etc/motd.tail                                                                \
/etc/subversion/config                                                        \
/etc/logcheck/ignore.d.server/local                                           \
#

# package specific httpd configs
HTTPCONFIGNAME=lighttpd.conf
HTTPCONFIGS=$(shell find /mirror/pkgs/*/$(HTTPCONFIGNAME))
CONFIGS+=$(HTTPCONFIGS:/mirror/pkgs/%/$(HTTPCONFIGNAME)=/etc/lighttpd/conf-available/80-%.conf)



## configs for the leader
LEADERCONFIGS+=\
/etc/cron.d/geoul-leader                                                      \
perms-leader                                                                  \
#
LEADERPACKAGES+=\
#

.PHONY: node node-packages-installed \
    leader leader-packages-installed \
    perms perms-leader \
    #

## node types
node: node-packages-installed $(CONFIGS)
leader: node leader-packages-installed $(LEADERCONFIGS)
	$(MAKE) -C ../www/self
	[ -e /mirror/log/size/df.rrd ] || /mirror/bin/create-df.rrd create

node-packages-installed:
	apt-get -qq -y install $(PACKAGES)
leader-packages-installed:
	apt-get -qq -y install $(LEADERPACKAGES)

perms:
	chown mirror:mirror /var/log/geoul/*
	chmod g+w /var/log/geoul/*
	chown www-data:mirror /var/log/geoul/httpd
perms-leader:
	cd /mirror && \
	find . \( -path ./ftp -o -path ./log -o -path ./pkgs/\*/data -o -path ./nodes/\*/storage \) -prune -o \
	    -type d -exec setfacl -m g:mirror:rwx {} \; -exec setfacl -d -m g:mirror:rw {} \; -o \
	    -type f ! -name .\*.log.gz ! -name log ! -name lock ! -name lock.\* -exec setfacl -m g:mirror:rw {} \;
	chmod u=rwx,go=rx /mirror
	# ~mirror/.ssh for push triggers
	cd /mirror/.ssh && \
	chmod -R a-w,u+w . && \
	chmod a+rx,u+w . && \
	chmod a=,u=r id_rsa *_sshkey

## special rules for individual config
INSTALL=install -m a+r

# sysctl
/etc/sysctl.conf: sysctl.conf
	$(INSTALL) $< $@
	sysctl -p

# cron
/etc/cron.d/geoul: crontab.node
	$(INSTALL) $< $@
	invoke-rc.d cron reload
/etc/cron.d/geoul-leader: crontab.leader
	$(INSTALL) $< $@
	invoke-rc.d cron reload

# logs
/var/log/geoul/%/:
	mkdir -p $@
	chown mirror:mirror $@
	chmod g+w $@
/etc/logrotate.d/geoul: logrotate.conf
	$(INSTALL) $< $@

# mail
/etc/aliases: aliases
	$(INSTALL) $< $@
	newaliases

# sudoers
/etc/sudoers.d/geoul: sudoers
	$(INSTALL) -m a=r,o= $< $@

# lighttpd
/etc/lighttpd/lighttpd.conf: lighttpd.conf
	$(INSTALL) $< $@
	until invoke-rc.d lighttpd restart; do sleep 1; done
/etc/lighttpd/conf-available/80-%.conf: /mirror/pkgs/%/$(HTTPCONFIGNAME) | /etc/lighttpd/lighttpd.conf
	$(INSTALL) $< $@
	lighty-enable-mod $(@F:80-%.conf=%)
	until invoke-rc.d lighttpd restart; do sleep 1; done

# vsftpd
/etc/vsftpd.conf: vsftpd.conf
	$(INSTALL) $< $@
	invoke-rc.d vsftpd reload

# rsyncd
/etc/rsyncd.conf: rsyncd.conf
	$(INSTALL) $< $@
	sudo vim /etc/default/rsync +%s/RSYNC_ENABLE=false/RSYNC_ENABLE=true/ +wq
	invoke-rc.d rsync restart

# motd
/etc/motd.tail: motd
	$(INSTALL) $< $@

# subversion
/etc/subversion/config: subversion.config
	$(INSTALL) $< $@

# logcheck
/etc/logcheck/ignore.d.server/local: logcheck.ignore
	$(INSTALL) $< $@
	sudo vim /etc/logcheck/logcheck.conf +'%s/^#INTRO=1/INTRO=0/ | %s/^REPORTLEVEL=.*/REPORTLEVEL="server"/' +wq

# default rule is to just install the config file from here
.SECONDEXPANSION:
/etc/%: $$(@F)
	$(INSTALL) $< $@

