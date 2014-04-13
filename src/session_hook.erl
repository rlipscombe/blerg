-module(session_hook).
-export([onrequest/1]).

onrequest(Req) ->
    {Cookie, Req2} = cowboy_req:cookie(<<"session_id">>, Req),
    Session = session:get_session(Cookie),
    cowboy_req:set_meta(session_id, Session, Req2).
