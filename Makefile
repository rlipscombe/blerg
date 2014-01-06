.PHONY: all rebar get-deps compile

all: get-deps compile

get-deps:
	./rebar get-deps

compile: get-deps
	./rebar compile

dev: compile
	PATH=.:${PATH} erl -pa apps/*/ebin -pz deps/*/ebin -sname blerg -s blerg -s ssync -config dev.config

prod: compile
	erl -pa apps/*/ebin -pz deps/*/ebin -sname blerg -s blerg -config prod.config

