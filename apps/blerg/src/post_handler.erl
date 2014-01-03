-module(post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    Site = [{name, "Roger's Blog"}],
    {Id, Req2} = cowboy_req:binding(id, Req),
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Post = transform:post(posts:by_id(Id)),
    Title = proplists:get_value(title, Post),
    {ok, Body} = post_dtl:render([{title, Title}, {site, Site}, {post, Post}]),
    {ok, Req3} = cowboy_req:reply(200, Headers, Body, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.

