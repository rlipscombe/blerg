-module(login_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    handle(Method, Req2, State).

handle(<<"POST">>, Req, State) ->
    {ok, CookieOpts} = application:get_env(blerg, cookies),
    {ok, Form, Req2} = cowboy_req:body_qs(Req),

    UserName = proplists:get_value(<<"username">>, Form),
    Password = binary_to_list(proplists:get_value(<<"password">>, Form)),

    case blerg_db:equery("SELECT id, password_hash FROM users WHERE name = $1", [UserName]) of
        {ok, _Cols, []} ->
            % Mitigate timing attacks by running bcrypt anyway...
            FakeHash = "$2a$12$y9EdeWdcfUUC0za61U3SFeipoRnWhmXdE3Ha/nG4Msq2z5oEOXNaC",
            bcrypt:hashpw(Password, FakeHash),
            lager:warning("Invalid username or password (1)"),
            render([{alert, "Invalid username or password."}], Req2, State);
        {ok, _Cols, [{_, <<"!">>}]} ->
            % @todo This should be reported as "invalid username or password".
            lager:warning("Account ~p has no password set.", [UserName]),
            render([{alert, "Invalid username or password."}], Req2, State);
        {ok, _Cols, [{UserId, Hash}]} ->
            Hash2 = binary_to_list(Hash),
            case bcrypt:hashpw(Password, Hash2) of
                {ok, Hash2} ->
                    User = [{id, UserId},
                            {name, UserName},
                            {can, [{create_posts, true}, {edit_posts, true}]}],
                    Session = [{user, User}],
                    {ok, SessionId} = session_store:new_session(Session),
                    Req3 = cowboy_req:set_resp_cookie(<<"sessionid">>, SessionId, CookieOpts, Req2),
                    Req4 = redirect:temporary("/", Req3),
                    {ok, Req4, State};
                _ ->
                    lager:warning("Invalid username or password (2)"),
                    render([{alert, "Invalid username or password."}], Req2, State)
            end
    end;
handle(_, Req, State) ->
    render([], Req, State).

render(Props, Req, State) ->
    Site = proplists:get_value(site, State),
    Title = proplists:get_value(name, Site),
    Props2 = Props ++ [{title, Title}, {site, Site}],

    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = login_dtl:render(Props2),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
