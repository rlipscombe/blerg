-module(blerg_db).
-export([equery/1, equery/2]).

-define(POOL_NAME, blerg_db).

equery(Stmt) ->
    equery(Stmt, []).

equery(Stmt, Params) ->
    poolboy:transaction(?POOL_NAME, fun(W) ->
                gen_server:call(W, {equery, Stmt, Params})
        end).

