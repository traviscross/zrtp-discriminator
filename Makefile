# makefile

md := $(wildcard *.md)
html := $(patsubst %.md,%.html,$(md))
epub := $(patsubst %.md,%.epub,$(md))

all: $(html) $(epub)

%.html: %.md
	pandoc -o $@ $<

%.epub: %.md
	pandoc -o $@ $<
