-module(blerg_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    folsom_metrics:new_histogram({blerg, request_time}),
    folsom_metrics:new_histogram({blerg, transform_post}),
    folsom_metrics:new_histogram({blerg, render, index_dtl}),

    folsom_metrics:new_histogram({index_handler, posts, index}),
    folsom_metrics:new_histogram({index_handler, posts, transform}),
    folsom_metrics:new_histogram({blerg_db, checkout}),
    folsom_metrics:new_histogram({blerg_db, transaction}),
    folsom_metrics:new_counter({blerg_db, active_workers}),
    folsom_metrics:new_counter({blerg_db, processes_waiting}),
    ok = start_cowboy(),
    blerg_sup:start_link().

stop(_State) ->
    ok.

start_cowboy() ->
    {ok, Rev} = application:get_key(blerg, vsn),
    Site = [{name, "Roger's Blog"}, {rev, Rev}],

    Opts = [{site, Site}],
    Routes = [
              %{'_', cowboy_static, {priv_file, blerg, "maintenance.html"}},

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
            {"/robots.txt", cowboy_static, {priv_file, blerg, "robots.txt",
                                            [{mimetypes, {<<"text">>, <<"plain">>, []}}]}},
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
                                 {middlewares, [timing_middleware, cowboy_router, cowboy_handler, timing_middleware]},
                                 {onrequest, fun session_hook:onrequest/1},
                                 {onresponse, OnResponse}]),
    ok.
