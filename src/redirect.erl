-module(redirect).
-export([to/2]).

to(Url, Req) when is_list(Url) ->
    to(list_to_binary(Url), Req);
to(Url, Req) when is_binary(Url) ->
    Headers = [{<<"location">>, Url}],
    {ok, Req2} = cowboy_req:reply(302, Headers, <<>>, Req),
    Req2.
