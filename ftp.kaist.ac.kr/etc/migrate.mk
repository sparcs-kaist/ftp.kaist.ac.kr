#!/usr/bin/make -f

FROM:=root@143.248.234.110

PKGS:=\
apache \
cpan \
cygwin \
debian \
eclipse \
fedora \
gentoo \
mozilla \
mplayer \
mplayer-www \
opensuse \
ubuntu \
apache \
cpan \
cygwin \
debian \
eclipse \
fedora \
gentoo \
mozilla \
mplayer \
mplayer-www \
opensuse \
ubuntu \
#

#.PHONY: $(PKGS) migrate
migrate: $(PKGS)
%: migrate.key
	rsync -avH -e 'ssh -c arcfour -i /mirror/etc/migrate.key' $(FROM):/mirror/pkgs/$@/data/ /mirror/pkgs/$@/data/

migrate.key:
	ssh-keygen -N "" -f $@
	cat $@.pub | ssh $(FROM) sh -c 'mkdir -p .ssh; tee -a .ssh/authorized_keys'
