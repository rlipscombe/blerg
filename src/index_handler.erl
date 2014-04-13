-module(index_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    Title = "Roger's Blog",
    {ok, Rev} = application:get_key(blerg, vsn),
    Site = [{name, "Roger's Blog"}, {rev, Rev}],
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = [transform:post(P) || P <- posts:index()],
    {ok, Body} = index_dtl:render([{title, Title}, {site, Site}, {posts, Posts}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

