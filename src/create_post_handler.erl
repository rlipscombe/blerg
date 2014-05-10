-module(create_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    State = Opts,
    {ok, Req, State}.

handle(Req, State) ->
    {User, Req2} = cowboy_req:meta(user, Req),
    handle(Req2, User, State).

handle(Req, undefined, State) ->
    lager:warning("Unauthorized create_post"),
    {ok, Req2} = cowboy_req:reply(401, [], ["Unauthorized"], Req),
    {ok, Req2, State};
handle(Req, User, State) ->
    Site = proplists:get_value(site, State),

    Title = "Create Post",
    Post = [{title, ""}, {body, <<"Editor goes here.">>}],

    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = edit_post_dtl:render([{title, Title}, {site, Site}, {post, Post}, {user, User}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
