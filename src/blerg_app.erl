-module(blerg_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ok = start_cowboy(),
    blerg_sup:start_link().

stop(_State) ->
    ok.

start_cowboy() ->
    Routes = [
            {"/", index_handler, []},

            % posts
            {"/post/create", create_post_handler, []},
            {"/post/save", save_post_handler, []},
            {"/post/:id/edit", edit_post_handler, []},
            {"/post/:id", post_handler, []},

            % tags
            {"/tag/:tag", tag_handler, []},

            % Syndication
            {"/feed", feed_handler, []},

            % static files
            {"/robots.txt", cowboy_static, {priv_file, blerg, "robots.txt"}},
            {"/favicon.ico", cowboy_static, {priv_file, blerg, "favicon.ico"}},
            {"/fonts/[...]", cowboy_static, {priv_dir, blerg, "fonts"}},
            {"/css/fonts/[...]", cowboy_static, {priv_dir, blerg, "fonts"}},
            {"/css/[...]", cowboy_static, {priv_dir, blerg, "css"}},
            {"/js/[...]", cowboy_static, {priv_dir, blerg, "js"}},
            {"/img/[...]", cowboy_static, {priv_dir, blerg, "img"}}
            ],
    Host = {'_', Routes},
    Dispatch = cowboy_router:compile([Host]),
    {ok, _} = cowboy:start_http(http, 100,
                                [{port, 4000}],
                                [{env, [{dispatch, Dispatch}]},
                                 {onresponse, fun error_hook/4}]),
    ok.

error_hook(404, _Headers, <<>>, Req) ->
    {Path, _} = cowboy_req:path(Req),
    case aliases:search(Path) of
        {ok, Url} -> redirect(Path, Url, Req);
        _ -> not_found(Path, Req)
    end;
error_hook(Code, _Headers, <<>>, Req)
        when is_integer(Code), Code >= 400 ->

    % Note that I'm ignoring the fact that this returns Req2.
    {Path, _} = cowboy_req:path(Req),
    {Method, _} = cowboy_req:method(Req),
    {Headers, _} = cowboy_req:headers(Req),
    lager:warning("HTTP Error ~p when ~p ~p ~p", [Code, Method, Path, Headers]),

    Body = ["HTTP Error ", integer_to_list(Code), $\n],
    Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
                                {<<"content-length">>, integer_to_list(iolist_size(Body))}),
    {ok, Req2} = cowboy_req:reply(Code, Headers2, Body, Req),
    Req2;
error_hook(Code, _Headers, _Body, Req)
        when is_integer(Code), Code =/= 200 ->
    {Path, _} = cowboy_req:path(Req),
    lager:info("~p when ~p", [Code, Path]),
    Req;
error_hook(_Code, _Headers, _Body, Req) ->
    Req.

redirect(Path, Url, Req) when is_list(Url) ->
    redirect(Path, list_to_binary(Url), Req);
redirect(Path, Url, Req) when is_binary(Url) ->
    lager:info("Redirecting ~p to ~p", [Path, Url]),
    Headers = [{<<"location">>, Url}],
    {ok, Req2} = cowboy_req:reply(302, Headers, <<>>, Req),
    Req2.

not_found(Path, Req) ->
    lager:warning("Not found: ~p", [Path]),
    Site = [{name, "Roger's Blog"}],
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = not_found_dtl:render([{site, Site}, {path, Path}]),
    {ok, Req2} = cowboy_req:reply(404, Headers, Body, Req),
    Req2.

