-module(blerg).
-export([start/0]).

start() ->
    blerg_util:ensure_started(blerg).

