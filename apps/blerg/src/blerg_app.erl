-module(blerg_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Routes = [
            {"/", index_handler, []}],
    Host = {'_', Routes},
    Dispatch = cowboy_router:compile([Host]),
    {ok, _} = cowboy:start_http(http, 100,
                                [{port, 4000}],
                                [{env, [{dispatch, Dispatch}]},
                                 {onresponse, fun error_hook/4}]),
    blerg_sup:start_link().

stop(_State) ->
    ok.

error_hook(Code, Headers, <<>>, Req)
        when is_integer(Code), Code >= 400 ->
    Body = ["HTTP Error ", integer_to_list(Code), $\n],
    Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
                                {<<"content-length">>, integer_to_list(iolist_size(Body))}),
    {ok, Req2} = cowboy_req:reply(Code, Headers2, Body, Req),
    Req2;
error_hook(_Code, _Headers, _Body, Req) ->
    Req.

