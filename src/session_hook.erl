-module(session_hook).
-export([onrequest/1]).

onrequest(Req) ->
    {Cookie, Req2} = cowboy_req:cookie(<<"session_id">>, Req),
    lager:debug("Cookie: ~p", [Cookie]),

    %Req3 = cowboy_req:set_meta(session_id, Session, Req2),
    %cowboy_req:set_meta(user, User, Req3),

    Req2.
