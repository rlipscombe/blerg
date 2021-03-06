-module(edit_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),

    % @todo This is fairly similar to create_post_handler; consider merging the two.

    {User, Req2} = cowboy_req:meta(user, Req),
    {Id, Req3} = cowboy_req:binding(id, Req2),

    {ok, Post} = posts:by_id(Id),
    lager:debug("Post ~p", [Post]),

    Title = proplists:get_value(title, Post),

    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = edit_post_dtl:render([{title, Title}, {site, Site}, {post, Post}, {user, User}]),
    {ok, Req4} = cowboy_req:reply(200, Headers, Body, Req3),
    {ok, Req4, State}.

terminate(_Reason, _Req, _State) ->
    ok.
