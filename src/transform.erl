-module(transform).
-export([post/2]).

-define(TEASER_LENGTH, 360).

post(P, Opts) ->
    folsom_metrics:histogram_timed_update(
      {blerg, transform_post},
      fun() ->
              transform_post(P, Opts, [])
      end).


transform_post([], _Opts, Acc) ->
    Acc;

transform_post([{created_at, Timestamp}|T], Opts, Acc0) ->
    Acc1 = [{created_at, Timestamp},
     {created_at_iso, datetime_to_iso(Timestamp)},
     {created_at_ago, timeago:in_words(Timestamp)} | Acc0],
    transform_post(T, Opts, Acc1);

transform_post([{body, Body}|T], Opts, Acc0) when is_binary(Body) ->
    transform_post([{body, binary_to_list(Body)}|T], Opts, Acc0);

transform_post([{body, Body}|T], Opts, Acc0) ->
    Acc1 = create_teaser(Body, proplists:get_value(teaser, Opts), Acc0),
    Acc2 = create_body(Body, proplists:get_value(body, Opts), Acc1),
    transform_post(T, Opts, Acc2);

transform_post([H|T], Opts, Acc0) ->
    transform_post(T, Opts, [H|Acc0]).

create_teaser(Body, true, Acc0) when length(Body) > ?TEASER_LENGTH ->
    [{teaser, markdown:conv(string:substr(Body, 1, ?TEASER_LENGTH) ++ "...")},
     {read_more, true} | Acc0];
create_teaser(Body, true, Acc0) ->
    [{teaser, markdown:conv(Body)},
     {read_more, false} | Acc0];
create_teaser(_Body, _, Acc0) ->
    Acc0.

create_body(Body, true, Acc0) ->
    [{body, markdown:conv(Body)} | Acc0];
create_body(_Body, _, Acc0) ->
    Acc0.

datetime_to_iso({{Ye,Mo,Da},{Ho,Mi,_Se}}) ->
    io_lib:format("~4..0B-~2..0B-~2..0B ~2..0B:~2..0B", [Ye, Mo, Da, Ho, Mi]).
