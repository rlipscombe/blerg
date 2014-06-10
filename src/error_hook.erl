-module(error_hook).
-export([onresponse/5]).

onresponse(404, _Headers, <<>>, Req, Opts) ->
    {Path, _} = cowboy_req:path(Req),
    case aliases:search(Path) of
        {ok, Url} ->
            lager:info("Redirecting ~p to ~p", [Path, Url]),
            redirect:permanent(Url, Req);
        _ ->
            not_found(Path, Req, Opts)
    end;
onresponse(Code, _Headers, _Body, Req, _Opts)
        when is_integer(Code), Code =:= 401 ->
    % @todo This ought to be middleware.
    lager:warning("Unauthorized"),
    Req;
onresponse(Code, _Headers, <<>>, Req, _Opts)
        when is_integer(Code), Code >= 400 ->

    % Note that I'm ignoring the fact that this returns Req2.
    {Path, _} = cowboy_req:path(Req),
    {Method, _} = cowboy_req:method(Req),
    {Headers, _} = cowboy_req:headers(Req),
    lager:warning("HTTP Error ~p when ~p ~p ~p", [Code, Method, Path, Headers]),

    Body = ["HTTP Error ", integer_to_list(Code), $\n],
    Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
                                {<<"content-length">>, integer_to_list(iolist_size(Body))}),
    Headers3 = lists:keyreplace(<<"content-type">>, 1, Headers2,
                                {<<"content-type">>, <<"text/plain">>}),
    {ok, Req2} = cowboy_req:reply(Code, Headers3, Body, Req),
    Req2;
onresponse(Code, _Headers, _Body, Req, _Opts)
        when is_integer(Code), Code =/= 200 ->
    {Path, _} = cowboy_req:path(Req),
    lager:info("~p when ~p", [Code, Path]),
    Req;
onresponse(_Code, _Headers, _Body, Req, _Opts) ->
    Req.

not_found(Path, Req, Opts) ->
    lager:warning("Not found: ~p", [Path]),

    {User, Req2} = cowboy_req:meta(user, Req),
    Site = proplists:get_value(site, Opts),
    Props = [{site, Site}, {path, Path}, {user, User}],
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = not_found_dtl:render(Props),
    {ok, Req3} = cowboy_req:reply(404, Headers, Body, Req2),
    Req3.
