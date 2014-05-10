-module(index_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    State = Opts,
    {ok, Req, State}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),
    Title = proplists:get_value(title, Site),
    {User, Req2} = cowboy_req:meta(user, Req),

    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = [transform:post(P) || P <- posts:index()],
    {ok, Body} = index_dtl:render([{site, Site}, {title, Title}, {posts, Posts}, {user, User}]),
    {ok, Req3} = cowboy_req:reply(200, Headers, Body, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
