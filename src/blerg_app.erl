-module(blerg_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ok = start_cowboy(),
    blerg_sup:start_link().

stop(_State) ->
    ok.

start_cowboy() ->
    {ok, Rev} = application:get_key(blerg, vsn),
    Site = [{name, "Roger's Blog"}, {rev, Rev}],

    Opts = [{site, Site}],
    Routes = [
            {"/", index_handler, Opts},

            % posts
            {"/post/create", create_post_handler, Opts},
            {"/post/save", save_post_handler, Opts},
            {"/post/:id/edit", [{id, int}], edit_post_handler, Opts},
            {"/post/:id", [{id, int}], post_handler, Opts},
            {"/post/:id/:slug", [{id, int}], post_handler, Opts},

            % tags
            {"/tag/:tag", tag_handler, Opts},

            % Syndication
            {"/feed", feed_handler, Opts},

            % Accounts
            {"/account/login", login_handler, Opts},
            {"/account/logout", logout_handler, Opts},

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

    OnResponse = fun(Code, Headers, Body, Req) ->
            error_hook:onresponse(Code, Headers, Body, Req, Opts)
    end,
    {ok, _} = cowboy:start_http(http, 100,
                                [{port, 4000}],
                                [{env, [{dispatch, Dispatch}]},
                                 {onrequest, fun session_hook:onrequest/1},
                                 {onresponse, OnResponse}]),
    ok.
