-module(feed_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).
-export([feed/0]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    %Title = "Roger's Blog",
    %{ok, Rev} = application:get_key(blerg, vsn),
    %Site = [{name, "Roger's Blog"}, {rev, Rev}],
    Headers = [{<<"content-type">>, <<"application/rss+xml">>}],
    Body = feed(),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

feed() ->
    Prolog = [],
    Feed = [{rss, [{version, "2.0"}], [{channel, [], []}]}],
    Xml = xmerl:export_simple(Feed, xmerl_xml, Prolog),
    unicode:characters_to_binary(Xml).

