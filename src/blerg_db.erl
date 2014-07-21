-module(blerg_db).
-export([equery/1, equery/2]).

-define(POOL_NAME, blerg_db).

equery(Stmt) ->
    equery(Stmt, []).

equery(Stmt, Params) ->
    transaction(fun(W) ->
                        gen_server:call(W, {equery, Stmt, Params}, infinity)
                end).

transaction(Fun) ->
    folsom_metrics:notify({blerg_db, processes_waiting}, {inc, 1}),
    W = folsom_metrics:histogram_timed_update({blerg_db, checkout},
                                             fun() -> poolboy:checkout(?POOL_NAME, true, infinity) end),
    folsom_metrics:notify({blerg_db, processes_waiting}, {dec, 1}),
    log_result(transaction(W, Fun)).

transaction(W, Fun) ->
    folsom_metrics:notify({blerg_db, active_workers}, {inc, 1}),
    try
        folsom_metrics:histogram_timed_update({blerg_db, transaction},
                                              fun() -> Fun(W) end)
    after
        ok = poolboy:checkin(?POOL_NAME, W),
        folsom_metrics:notify({blerg_db, active_workers}, {dec, 1})
    end.

log_result(Result) ->
    case element(1, Result) of
        error ->
            lager:error("~p", [Result]);
        _ ->
            ok
    end,
    Result.
