PROJECT = blerg
BASE_DIR = $(shell pwd)

ERLC_OPTS ?= -Werror +warn_export_all +warn_export_vars +warn_shadow_vars +warn_obsolete_guard +'{parse_transform, lager_transform}'

DEPS = lager cowboy erlydtl poolboy epgsql markdown bcrypt erlware_commons iso8601
dep_lager = git://github.com/basho/lager.git 2.0.0
dep_cowboy = pkg://cowboy
dep_erlydtl = git://github.com/rlipscombe/erlydtl.git
dep_poolboy = git://github.com/devinus/poolboy.git 1.0.1
dep_epgsql = git://github.com/wg/epgsql.git 1.4
dep_markdown = git://github.com/rlipscombe/erlmarkdown.git
dep_bcrypt = https://github.com/opscode/erlang-bcrypt
dep_erlware_commons = git://github.com/erlware/erlware_commons.git 4c97d4a
dep_iso8601 = git://github.com/seansawyer/erlang_iso8601.git 1.1.1

DEPS += ace
dep_ace = https://github.com/ajaxorg/ace-builds/

# Add '.' to the path, so that it can find rebar.
export PATH:=$(BASE_DIR):$(PATH)
-include erlang.mk
