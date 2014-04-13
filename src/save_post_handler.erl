-module(save_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    lager:debug("Save: ~p", [Req]),
    {ok, Form, Req2} = cowboy_req:body_qs(Req),
    lager:debug("Form: ~p", [Form]),
    Headers = [{<<"content-type">>, <<"text/plain">>}],
    {ok, Req3} = cowboy_req:reply(200, Headers, <<"OK">>, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
