BASE_DIR  = $(shell pwd)

.PHONY: all rebar get-deps compile

all: get-deps compile

get-deps:
	./rebar get-deps

compile: get-deps
	./rebar compile

c:
	./rebar compile skip_deps=true

clean:
	./rebar clean
	rm -rf deps

# can't use ln -sf, because it'll put the symlink inside the destination;
# can't use ln -sfT, because that's not supported on OS X, so do this:
ace: get-deps
	-rm priv/js/ace
	ln -s ../../deps/ace/src-min-noconflict priv/js/ace

ERL_LIBS := $(BASE_DIR):$(ERL_LIBS)

export ERL_LIBS

dev: compile ace
	erl -pa ebin -pz deps/*/ebin -sname blerg -s blerg -config etc/dev.config

d: c
	erl -pa ebin -pz deps/*/ebin -sname blerg -s blerg -config etc/dev.config
