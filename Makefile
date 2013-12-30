.PHONY: all rebar get-deps compile

all: rebar get-deps compile

rebar:
	test -x ./rebar || (curl https://raw.github.com/wiki/rebar/rebar/rebar -o rebar && chmod +x rebar)

get-deps:
	./rebar get-deps

compile: get-deps
	./rebar compile

dev: compile
	erl -pa apps/*/ebin -pz deps/*/ebin -sname blerg -s blerg -config dev.config

