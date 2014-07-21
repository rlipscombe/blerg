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
transform_post([H|T], Opts, Acc0) ->
    Acc1 = acc(transform_prop(H, Opts), Acc0),
    transform_post(T, Opts, Acc1).

transform_prop({created_at, Timestamp}, _Opts) ->
    [{created_at, Timestamp},
     {created_at_iso, datetime_to_iso(Timestamp)},
     {created_at_ago, timeago:in_words(Timestamp)}];
transform_prop({body, Body}, Opts) when is_binary(Body) ->
    transform_prop({body, binary_to_list(Body)}, Opts);
transform_prop({body, Body}, Opts) ->
    T = create_teaser(Body, proplists:get_value(teaser, Opts)),
    B = convert_body(Body, proplists:get_value(body, Opts)),
    T ++ B;
transform_prop(X, _Opts) ->
    X.

create_teaser(Body, true) when length(Body) > ?TEASER_LENGTH ->
    [{teaser, markdown:conv(string:substr(Body, 1, ?TEASER_LENGTH) ++ "...")},
     {read_more, true}];
create_teaser(Body, true) ->
    [{teaser, markdown:conv(Body)},
     {read_more, false}];
create_teaser(_Body, _) ->
    [].

convert_body(Body, true) ->
    [{body, markdown:conv(Body)}];
convert_body(_Body, _) ->
    [].

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
