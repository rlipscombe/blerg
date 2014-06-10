-module(redirect).
-export([permanent/2, temporary/2]).

permanent(Url, Req) ->
    to(301, Url, Req).

temporary(Url, Req) ->
    to(302, Url, Req).

to(Code, Url, Req) when is_list(Url) ->
    to(Code, list_to_binary(Url), Req);
to(Code, Url, Req) when is_binary(Url) ->
    Headers = [{<<"location">>, Url}],
    {ok, Req2} = cowboy_req:reply(Code, Headers, <<>>, Req),
    Req2.
