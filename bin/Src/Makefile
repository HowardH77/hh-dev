# Makefile for ~howard/bin/Src

SHELL = /bin/sh
CFLAGS = -I $(HOME)/dev/lib

All: hd lxargs ppsql printargs wordwrap 
	ln -f $? $(HOME)/bin

hd: hd.c

lxargs: lxargs.c

ppsql.c: ppsql.l

ppsql: ppsql.c

printargs: printargs.c

wordwrap: wordwrap.c

