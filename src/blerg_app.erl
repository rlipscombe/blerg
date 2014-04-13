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
                                 {onrequest, fun session_hook:onrequest/1},
                                 {onresponse, fun error_hook:onresponse/4}]),
    ok.
