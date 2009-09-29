# Makefile for GeoulCore
# Created: 2009-09-28
#
# Written by Jaeho Shin <netj@sparcs.org>.
# (C) 2006-2009, Geoul Project. (http://project.sparcs.org/geoul)

#COMMANDS := $(shell find src/*/*/main | sed 's:/main$$::; s:^src/[^/]*/::; s:/:.d/:g')
#EXPOSED_COMMANDS := $(shell find src/*/*/.expose | sed 's:/.expose$$::; s:^src/[^/]*/::; s:/:.d/:g')

.PHONY: all clean
all: stage/lib/geoul
clean:
	rm -rf stage .cmds.mk

include .cmds.mk
.cmds.mk: src/*/*
	./cmdscc stage/lib/geoul 'src/*/' $^ >$@
