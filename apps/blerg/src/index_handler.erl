-module(index_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

-define(TEASER_LENGTH, 360).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = [transform_post(P) || P <- posts:index()],
    {ok, Body} = index_dtl:render([{site, [{name, "Roger's Blog"}]}, {posts, Posts}]),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

transform_post(P) ->
    transform_post(P, []).

transform_post([], Acc) ->
    Acc;
transform_post([H|T], Acc) ->
    transform_post(T, acc(transform_prop(H), Acc)).

transform_prop({created_at, Timestamp}) ->
    [{created_at, Timestamp},
     {created_at_iso, datetime_to_iso(Timestamp)},
     {created_at_ago, timeago:in_words(Timestamp)}];
transform_prop({body, Body}) ->
    create_teaser(Body);
transform_prop(X) ->
    X.

create_teaser(Body) when is_binary(Body) ->
    create_teaser(binary_to_list(Body));
create_teaser(Body) when length(Body) > ?TEASER_LENGTH ->
    [{body, markdown:conv(string:substr(Body, 1, ?TEASER_LENGTH) ++ "...")},
     {read_more, true}];
create_teaser(Body) ->
    [{body, markdown:conv(Body)},
     {read_more, false}].

datetime_to_iso({{Ye,Mo,Da},{Ho,Mi,_Se}}) ->
    io_lib:format("~4..0B-~2..0B-~2..0B ~2..0B:~2..0B", [Ye, Mo, Da, Ho, Mi]).

acc([], Acc) ->
    Acc;
acc([H|T], Acc) ->
    acc(T, [H|Acc]);
acc(V, Acc) ->
    [V|Acc].

