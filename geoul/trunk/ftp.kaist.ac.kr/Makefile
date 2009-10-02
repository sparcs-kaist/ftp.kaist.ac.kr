# Makefile for Geoul/ftp.kaist.ac.kr configuration
# 
# Created: 2008-05-18
# 
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2008, Geoul Project. (http://ftp.kaist.ac.kr/geoul)

## configs for normal nodes
CONFIGS+=\
/etc/cron.d/geoul                                                             \
/etc/semiauto.master                                                          \
/etc/sysctl.conf                                                              \
/etc/aliases                                                                  \
/etc/admin-contact                                                            \
/etc/vsftpd.conf                                                              \
/var/log/geoul/ftpd/                                                          \
/etc/lighttpd/lighttpd.conf                                                   \
/var/log/geoul/httpd/                                                         \
/etc/rsyncd.conf                                                              \
/var/log/geoul/rsyncd/                                                        \
/var/log/geoul/cvsupd/                                                        \
/var/log/geoul/measure-usage/                                                 \
/etc/logrotate.d/geoul                                                        \
/etc/webalizer/webalizer.conf                                                 \
/etc/motd.tail                                                                \
/etc/subversion/config
#

# package specific httpd configs
HTTPCONFIGS=$(shell find /mirror/pkgs/*/lighttpd.conf)
CONFIGS+=$(HTTPCONFIGS:/mirror/pkgs/%/lighttpd.conf=/etc/lighttpd/conf-available/80-%.conf)



## configs for the leader
LEADERCONFIGS+=\
/etc/cron.d/geoul-leader                                                      \
/etc/auto.mirror                                                              \
#


## node types
node: $(CONFIGS)
leader: node $(LEADERCONFIGS)

INSTALL=install -m a+r


## special rules for individual config

# sysctl
/etc/sysctl.conf: etc/sysctl.conf
	$(INSTALL) $< $@
	sysctl -p

# cron
/etc/cron.d/geoul: svcs/cron/crontab.node
	$(INSTALL) $< $@
	invoke-rc.d cron reload
/etc/cron.d/geoul-leader: svcs/cron/crontab.leader
	$(INSTALL) $< $@
	invoke-rc.d cron reload

# logs
/var/log/geoul/%/:
	mkdir -p $@
	chown mirror:mirror $@
	chmod g+w $@
/etc/logrotate.d/geoul: etc/logrotate.conf
	$(INSTALL) $< $@

# mail
/etc/aliases: etc/aliases
	$(INSTALL) $< $@
	newaliases

# lighttpd
/etc/lighttpd/lighttpd.conf: svcs/http/lighttpd.conf
	$(INSTALL) $< $@
	until svcs/http/rc restart; do sleep 1; done
/etc/lighttpd/conf-available/80-%.conf: pkgs/%/lighttpd.conf | /etc/lighttpd/lighttpd.conf
	$(INSTALL) $< $@
	lighty-enable-mod $(@F:80-%.conf=%)
	until svcs/http/rc restart; do sleep 1; done

# vsftpd
/etc/vsftpd.conf: svcs/ftp/vsftpd.conf
	$(INSTALL) $< $@
	svcs/ftp/rc reload

# rsyncd
/etc/rsyncd.conf: svcs/rsync/rsyncd.conf
	$(INSTALL) $< $@
	svcs/rsync/rc restart

# motd
/etc/motd.tail: www/self/.message
	$(INSTALL) $< $@

# subversion
/etc/subversion/config: etc/subversion.config
	$(INSTALL) $< $@


# default rule is to just install the config file from here
.SECONDEXPANSION:
/etc/%: $$(@F)
	$(INSTALL) $< $@

