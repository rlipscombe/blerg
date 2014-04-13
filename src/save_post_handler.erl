-module(save_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, Form, Req2} = cowboy_req:body_qs(Req),

    % Note: we don't simply use the incoming
    % proplist -- it's not trusted.
    Title = proplists:get_value(<<"title">>, Form),
    Body = proplists:get_value(<<"markdown">>, Form),

    AuthorId = 1,       % @todo It's always me at the moment.
    CreatedAt = calendar:now_to_universal_time(os:timestamp()),
    posts:save([{title, Title},
                {author_id, AuthorId},
                {created_at, CreatedAt},
                {body, Body}]),

    % @todo Return JSON with the ID.
    Headers = [{<<"content-type">>, <<"text/plain">>}],
    {ok, Req3} = cowboy_req:reply(200, Headers, <<"OK">>, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
