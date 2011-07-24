# Makefile for self materials of ftp.kaist.ac.kr
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2008-06-22

FTPROOT=/mirror/ftp
FILES=.message index.html id_rsa.pub

all: $(FILES:%=$(FTPROOT)/%)

index.html: index.html.in $(FTPROOT)
	cp -f $< $@
	rm -f .index.html.swp
	chmod +w $@
	screen -Dm vim $@ +1 +'/\(begin\|end\) of contents' +'norm jVnkdk' \
	    +'r!./list-data-links $(FTPROOT)' \
	    +'norm VNj=ZZ'
	chmod a=r $@

.SECONDEXPANSION:
$(FTPROOT)/%: $$(@F)
	sudo -u mirror install -m a=r $< $@

