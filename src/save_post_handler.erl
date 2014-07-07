-module(save_post_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    {User, Req2} = cowboy_req:meta(user, Req),
    handle(Req2, User, State).

handle(Req, undefined, State) ->
    lager:warning("Unauthorized save_post"),
    {ok, Req2} = cowboy_req:reply(401, [], ["Unauthorized"], Req),
    {ok, Req2, State};
handle(Req, User, State) ->
    {ok, Form, Req2} = cowboy_req:body_qs(Req),

    % If the incoming request already has an ID, then it's an update;
    Id = proplists:get_value(<<"id">>, Form),

    % Note: we don't simply use the incoming
    % proplist -- it's not trusted.
    Title = proplists:get_value(<<"title">>, Form),
    % @todo Rename 'markdown' to 'body'?
    Body = proplists:get_value(<<"markdown">>, Form),

    AuthorId = proplists:get_value(id, User),
    CreatedAt = calendar:now_to_universal_time(os:timestamp()),

    Post = [{title, Title},
            {author_id, AuthorId},
            {created_at, CreatedAt},
            {body, Body}],

    {ok, NewId} = save(Id, Post),

    {ok, Req3} = reply(NewId, Req2),
    {ok, Req3, State}.

save(<<>>, Post) ->
    % @todo Verify permissions to create a new post.
    posts:create(Post);
save(Id, Post) ->
    Id2 = list_to_integer(binary_to_list(Id)),
    % @todo Verify permissions to edit this post.
    posts:update(Id2, Post).

reply(Id, Req) ->
    Headers = [{<<"content-type">>, <<"application/json">>}],
    Body = io_lib:format("{\"id\":~B}", [Id]),
    cowboy_req:reply(200, Headers, Body, Req).

terminate(_Reason, _Req, _State) ->
    ok.
