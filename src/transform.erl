-module(transform).
-export([post/1]).

-define(TEASER_LENGTH, 360).

post(P) ->
    folsom_metrics:histogram_timed_update(
      {blerg, transform_post},
      fun() ->
              transform_post(P, [])
      end).

transform_post([], Acc) ->
    Acc;
transform_post([H|T], Acc) ->
    transform_post(T, acc(transform_prop(H), Acc)).

transform_prop({created_at, Timestamp}) ->
    [{created_at, Timestamp},
     {created_at_iso, datetime_to_iso(Timestamp)},
     {created_at_ago, timeago:in_words(Timestamp)}];
transform_prop({body, Body}) when is_binary(Body) ->
    transform_prop({body, binary_to_list(Body)});
transform_prop({body, Body}) ->
    Teaser = create_teaser(Body),
    [{body, convert_body(Body)}] ++ Teaser;
transform_prop(X) ->
    X.

create_teaser(Body) when length(Body) > ?TEASER_LENGTH ->
    [{teaser, markdown:conv(string:substr(Body, 1, ?TEASER_LENGTH) ++ "...")},
     {read_more, true}];
create_teaser(Body) ->
    [{teaser, markdown:conv(Body)},
     {read_more, false}].

convert_body(Body) ->
    markdown:conv(Body).

datetime_to_iso({{Ye,Mo,Da},{Ho,Mi,_Se}}) ->
    io_lib:format("~4..0B-~2..0B-~2..0B ~2..0B:~2..0B", [Ye, Mo, Da, Ho, Mi]).

%% @doc We can transform a single item into multiple items. The 'acc' function
%% allows accumulating these into a single list. Essentially, it flattens as it
%% goes.
%% Note: lists:append won't work -- we have a mixture of lists and terms.
acc([], Acc) ->
    Acc;
acc([H|T], Acc) ->
    acc(T, [H|Acc]);
acc(V, Acc) ->
    [V|Acc].
