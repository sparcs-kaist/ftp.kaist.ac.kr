# Makefile for self materials of ftp.kaist.ac.kr
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2008-06-22

FTPROOT=/mirror/ftp
FILES=.message index.html id_rsa.pub

all: $(FILES:%=$(FTPROOT)/%)

index.html: index.html.in $(FTPROOT)
	cp -f $< $@
	vim $@ +1 +'/\(begin\|end\) of contents' +'norm jVnkdk' \
	    +'r!cd $(FTPROOT) && find * -maxdepth 0 -type d | sort -f | \
	    	sed -e '\''s:.*:<li><a href="&/">&</a></li>:'\' \
	    +'norm VNj=ZZ'

.SECONDEXPANSION:
$(FTPROOT)/%: $$(@F)
	install -m a=r $< $@

