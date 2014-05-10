-module(session_hook).
-export([onrequest/1]).

onrequest(Req) ->
    {Cookie, Req2} = cowboy_req:cookie(<<"sessionid">>, Req),

    Session = session_store:get_session(Cookie),
    set_session_meta(Session, Req2).

set_session_meta(undefined, Req) ->
    Req;
set_session_meta(Session, Req) ->
    Req2 = cowboy_req:set_meta(session, Session, Req),
    User = proplists:get_value(user, Session),
    Req3 = cowboy_req:set_meta(user, User, Req2),

    Req3.
