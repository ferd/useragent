.PHONY: all test clean edoc
	PREFIX:=../
DEST:=$(PREFIX)$(PROJECT)

REBAR=./rebar

all:
	@$(REBAR) get-deps compile

get-deps:
	@$(REBAR) get-deps

edoc:
	@$(REBAR) doc

test:
	@$(REBAR) compile eunit skip_deps=true

clean:
	@rm -rf deps/ ebin/ .eunit/* test/*.beam

build_plt:
	@$(REBAR) build-plt

