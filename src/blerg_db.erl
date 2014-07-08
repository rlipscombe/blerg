-module(blerg_db).
-export([equery/1, equery/2]).

-define(POOL_NAME, blerg_db).
-define(CHECKOUT_TIMEOUT_MS, 30000).
-define(CALL_TIMEOUT_MS, 30000).

equery(Stmt) ->
    equery(Stmt, []).

equery(Stmt, Params) ->
    log_result(poolboy:transaction(?POOL_NAME, fun(W) ->
                gen_server:call(W, {equery, Stmt, Params}, ?CALL_TIMEOUT_MS)
            end, ?CHECKOUT_TIMEOUT_MS)).

log_result(Result) ->
    case element(1, Result) of
        error ->
            lager:error("~p", [Result]);
        _ ->
            ok
    end,
    Result.
