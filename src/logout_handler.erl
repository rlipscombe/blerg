-module(logout_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    {ok, CookieOpts} = application:get_env(blerg, cookies),
    Req2 = cowboy_req:set_resp_cookie(<<"sessionid">>, <<>>, CookieOpts, Req),
    Req3 = redirect:temporary("/", Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
