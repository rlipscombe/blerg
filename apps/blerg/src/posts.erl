-module(posts).
-export([index/0, by_id/1]).

index() -> 
    {ok, Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, u.name AS author, p.created_at, p.body
                                         FROM posts p
                                         JOIN users u ON p.author_id = u.id
                                         ORDER BY p.created_at DESC
                                      LIMIT 10"),
    [convert_to_proplist(Cols, R) || R <- Rows].

convert_to_proplist(Cols, Row) when is_tuple(Row) ->
    convert_to_proplist(Cols, tuple_to_list(Row));
convert_to_proplist(Cols, Row) when is_list(Row) ->
    % C = {column,<<"id">>,int4,4,-1,1}
    % R = Value
    F = fun({column, Name, _, _, _, _}, R) ->
            {list_to_atom(binary_to_list(Name)), R}
    end,
    lists:zipwith(F, Cols, Row).

by_id(Id) when is_binary(Id) ->
    by_id(binary_to_list(Id));
by_id(Id) when is_list(Id) ->
    by_id(list_to_integer(Id));
by_id(Id) ->
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

