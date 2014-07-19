BASE_DIR = $(shell pwd)
SHORT_VSN ?= $(shell ./git-vsn --short)

REBAR ?= $(BASE_DIR)/rebar
RELX ?= $(BASE_DIR)/relx

all:
	$(REBAR) get-deps
	$(REBAR) compile
	$(RELX)

console: all
	_rel/blerg/bin/blerg console

tarball: all
	tar -C _rel -z -cf blerg-latest.tar.gz blerg
