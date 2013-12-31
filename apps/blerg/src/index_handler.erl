-module(index_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    Site = {name, "Roger's Blog"},
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = posts:index(),
    lager:info("Posts: ~p", [Posts]),
    {ok, Body} = index_dtl:render([{site, Site}, {posts, Posts}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

