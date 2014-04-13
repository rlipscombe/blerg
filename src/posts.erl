-module(posts).
-export([index/0, by_id/1, feed/0, tagged/1]).

index() -> 
    {ok, Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, u.name AS author, p.created_at, p.body
                                         FROM posts p
                                         JOIN users u ON p.author_id = u.id
                                         ORDER BY p.created_at DESC"),
    convert_to_proplists(Cols, Rows).

by_id(Id) when is_binary(Id) ->
    by_id(binary_to_list(Id));
by_id(Id) when is_list(Id) ->
    by_id(list_to_integer(Id));
by_id(Id) ->
    % @todo Use exceptions instead?
    case post_by_id(Id) of
        {ok, Post} ->
            Tags = tags_for_post_id(Id),
            {ok, [{tags, Tags}|Post]};
        E -> E
    end.

post_by_id(Id) ->
    {ok, Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, u.name AS author, p.created_at, p.body
                                        FROM posts p
                                        JOIN users u ON p.author_id = u.id
                                      WHERE p.id = $1", [Id]),
    case Rows of
        [R] ->
            {ok, convert_to_proplist(Cols, R)};
        [] ->
            {error, not_found}
    end.

tags_for_post_id(Id) ->
    {ok, _Cols, Rows} = blerg_db:equery("SELECT t.name
                                      FROM tags t
                                      JOIN post_tags pt ON pt.tag_id = t.id
                                       WHERE pt.post_id = $1", [Id]),
    [T || {T} <- Rows].

feed() ->
    {ok, Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, p.created_at, p.body
                                       FROM posts p
                                       WHERE p.created_at > CURRENT_DATE - INTERVAL '6 months'
                                       ORDER BY p.created_at DESC
                                       LIMIT 20"),
    convert_to_proplists(Cols, Rows).

tagged(Tag) ->
    % @todo This returns an empty set for unknown tags; we might prefer an error.
    {ok, Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, p.created_at, p.body
                                      FROM posts p
                                      INNER JOIN post_tags pt ON pt.post_id = p.id
                                      INNER JOIN tags t ON t.id = pt.tag_id
                                      WHERE t.name = $1
                                       ORDER BY p.created_at DESC", [Tag]),
    convert_to_proplists(Cols, Rows).

convert_to_proplists(Cols, Rows) ->
    [convert_to_proplist(Cols, R) || R <- Rows].

convert_to_proplist(Cols, Row) when is_tuple(Row) ->
    convert_to_proplist(Cols, tuple_to_list(Row));
convert_to_proplist(Cols, Row) when is_list(Row) ->
    lists:zipwith(fun convert_to_item/2, Cols, Row).

% C = {column,<<"id">>,int4,4,-1,1}
% R = Value
convert_to_item({column, Name, timestamp, _, _, _}, {{Ye,Mo,Da},{Ho,Mi,Se}}) ->
    {list_to_atom(binary_to_list(Name)), {{Ye,Mo,Da},{Ho,Mi,trunc(Se)}}};
convert_to_item({column, Name, _Type, _, _, _}, R) ->
    {list_to_atom(binary_to_list(Name)), R}.
