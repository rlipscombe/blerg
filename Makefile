BASE_DIR = $(shell pwd)
SHORT_VSN ?= $(shell ./git-vsn --short)

REBAR ?= $(BASE_DIR)/rebar
RELX ?= $(BASE_DIR)/relx

top:
	$(REBAR) get-deps
	$(REBAR) compile
	$(RELX)

console: top
	_rel/blerg/bin/blerg console
