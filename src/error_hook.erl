-module(error_hook).
-export([onresponse/4]).

onresponse(404, _Headers, <<>>, Req) ->
    {Path, _} = cowboy_req:path(Req),
    case aliases:search(Path) of
        {ok, Url} ->
            lager:info("Redirecting ~p to ~p", [Path, Url]),
            redirect:to(Url, Req);
        _ ->
            not_found(Path, Req)
    end;
onresponse(Code, _Headers, <<>>, Req)
        when is_integer(Code), Code >= 400 ->

    % Note that I'm ignoring the fact that this returns Req2.
    {Path, _} = cowboy_req:path(Req),
    {Method, _} = cowboy_req:method(Req),
    {Headers, _} = cowboy_req:headers(Req),
    lager:warning("HTTP Error ~p when ~p ~p ~p", [Code, Method, Path, Headers]),

    Body = ["HTTP Error ", integer_to_list(Code), $\n],
    Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
                                {<<"content-length">>, integer_to_list(iolist_size(Body))}),
    {ok, Req2} = cowboy_req:reply(Code, Headers2, Body, Req),
    Req2;
onresponse(Code, _Headers, _Body, Req)
        when is_integer(Code), Code =/= 200 ->
    {Path, _} = cowboy_req:path(Req),
    lager:info("~p when ~p", [Code, Path]),
    Req;
onresponse(_Code, _Headers, _Body, Req) ->
    Req.

not_found(Path, Req) ->
    lager:warning("Not found: ~p", [Path]),
    Site = [{name, "Roger's Blog"}],
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = not_found_dtl:render([{site, Site}, {path, Path}]),
    {ok, Req2} = cowboy_req:reply(404, Headers, Body, Req),
    Req2.
