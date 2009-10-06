# Makefile for GeoulCore
# Created: 2009-09-28
#
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2009, Geoul Project. (http://project.sparcs.org/geoul)

COMMANDS := geoul regularly synchronized geoul-sync

.SUFFIXES:
.PHONY: all clean
STAGED_COMMANDS := $(COMMANDS:%=stage/bin/%)
all: $(STAGED_COMMANDS) stage/lib/geoul
clean:
	rm -rf stage .ctk.mk

$(STAGED_COMMANDS): stage/bin
	ln -sfn ../$(@:stage/bin/%=lib/geoul/%) $@
stage/bin:
	mkdir -p $@

.ctk.mk: src/*/* src/util/.sh
	./ctkcc stage/lib/geoul 'src/*/' $^ >$@
include .ctk.mk
