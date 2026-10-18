# Makefile for self materials of ftp.kaist.ac.kr
# Author: Jaeho Shin <netj@sparcs.org>, Khinenw <nenw@sparcs.org>
# Created: 2008-06-22
#
# Update: 2020-07-24, removed index.html because of new frontend; the original version (www/self/legacy/) was removed later and remains in git history
#         WARNING: The new frontend is not built from this Makefile, please refer to sparcs-kaist/geoul-mainpage

FTPROOT=$(shell readlink -f /mirror/ftp)
FILES=.message id_rsa.pub robots.txt

all: $(FILES:%=$(FTPROOT)/%)

robots.txt: generate-robots-txt.sh
	./$< >$@

.SECONDEXPANSION:
$(FTPROOT)/%: $$(@F)
	sudo -u mirror install -m a=r $< $@

