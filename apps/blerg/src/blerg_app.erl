-module(blerg_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ok = start_cowboy(),
    ok = start_poolboy(),
    blerg_sup:start_link().

stop(_State) ->
    ok.

start_cowboy() ->
    Routes = [
            {"/", index_handler, []},

            % posts
            {"/post/create", create_post_handler, []},
            {"/post/:id", post_handler, []},

            % static files
            {"/favicon.ico", cowboy_static, {priv_file, blerg, "favicon.ico"}},
            {"/css/[...]", cowboy_static, {priv_dir, blerg, "css"}},
            {"/js/[...]", cowboy_static, {priv_dir, blerg, "js"}}
            ],
    Host = {'_', Routes},
    Dispatch = cowboy_router:compile([Host]),
    {ok, _} = cowboy:start_http(http, 100,
                                [{port, 4000}],
                                [{env, [{dispatch, Dispatch}]},
                                 {onresponse, fun error_hook/4}]),
    ok.

start_poolboy() ->
    {ok, _} = blerg_db_sup:start_link(),
    ok.

error_hook(Code, Headers, <<>>, Req)
        when is_integer(Code), Code >= 400 ->

    % Note that I'm ignoring the fact that this returns Req2.
    {Path, _} = cowboy_req:path(Req),
    lager:warning("HTTP Error ~p when ~p", [Code, Path]),

    Body = ["HTTP Error ", integer_to_list(Code), $\n],
    Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
                                {<<"content-length">>, integer_to_list(iolist_size(Body))}),
    {ok, Req2} = cowboy_req:reply(Code, Headers2, Body, Req),
    Req2;
error_hook(_Code, _Headers, _Body, Req) ->
    Req.

