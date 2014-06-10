-module(post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),

    {User, Req2} = cowboy_req:meta(user, Req),
    {Id, Req3} = cowboy_req:binding(id, Req2),
    {Slug, Req4} = cowboy_req:binding(slug, Req3),
    reply(posts:by_id(Id), Slug, Site, User, Req4, State).

reply({ok, P}, Slug, Site, User, Req, State) ->
    %% If there is no slug, or if the user-specified slug doesn't match the
    %% expected slug, issue a 301 redirect to the canonical URL.
    ExpectedSlug = proplists:get_value(slug, P),
    case Slug of
        ExpectedSlug ->
            render_post(P, Site, User, Req, State);
        _ ->
            redirect_to(P, Req, State)
    end;
reply({error, not_found}, _Slug, Site, User, Req, State) ->
    {Path, _} = cowboy_req:path(Req),
    lager:warning("Not found: ~p", [Path]),
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = not_found_dtl:render([{site, Site}, {user, User}, {path, Path}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

render_post(P, Site, User, Req, State) ->
    Post = transform:post(P),
    Title = proplists:get_value(title, Post),
    Headers = [{<<"content-type">>, <<"text/html">>}],
    {ok, Body} = post_dtl:render([{title, Title}, {site, Site}, {user, User}, {post, Post}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

redirect_to(P, Req, State) ->
    Id = integer_to_list(proplists:get_value(id, P)),
    Slug = proplists:get_value(slug, P),
    Url = ["/post/", Id, "/", Slug],
    lager:debug("~p", [Url]),
    Req2 = redirect:temporary(Url, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
