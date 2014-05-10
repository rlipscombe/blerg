-module(post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),

    {Id, Req2} = cowboy_req:binding(id, Req),
    reply(posts:by_id(Id), Site, Req2, State).

reply({ok, P}, Site, Req, State) ->
    Post = transform:post(P),
    Title = proplists:get_value(title, Post),
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = post_dtl:render([{title, Title}, {site, Site}, {post, Post}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State};
reply({error, not_found}, Site, Req, State) ->
    {Path, _} = cowboy_req:path(Req),
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = not_found_dtl:render([{site, Site}, {path, Path}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
