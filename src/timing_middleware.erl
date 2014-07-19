-module(timing_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    Req2 = case cowboy_req:meta(request_start, Req) of
               {undefined, R} ->
                   cowboy_req:set_meta(request_start, os:timestamp(), R);
               {RequestStart, R} ->
                   ElapsedMicroSecs = timer:now_diff(os:timestamp(), RequestStart),
                   {URL, R2} = cowboy_req:url(R),
                   lager:info("Request to ~s took ~b us.", [URL, ElapsedMicroSecs]),
                   R2
           end,
    {ok, Req2, Env}.
