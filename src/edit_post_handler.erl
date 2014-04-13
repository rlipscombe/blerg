-module(edit_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    % @todo This is fairly similar to create_post_handler; consider merging the two.
    Title = "Create Post",
    Site = [{name, "Roger's Blog"}],
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = edit_post_dtl:render([{title, Title}, {site, Site}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
