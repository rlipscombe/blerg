.PHONY: all rebar get-deps compile

all: get-deps compile

get-deps:
	./rebar get-deps

compile: get-deps
	./rebar compile

# can't use ln -sf, because it'll put the symlink inside the destination;
# can't use ln -sfT, because that's not supported on OS X, so do this:
ace: get-deps
	-rm apps/blerg/priv/js/ace
	ln -s ../../../../deps/ace/src-min-noconflict apps/blerg/priv/js/ace

dev: compile ace
	PATH=.:${PATH} erl -pa apps/*/ebin -pz deps/*/ebin -sname blerg -s blerg -config dev.config

