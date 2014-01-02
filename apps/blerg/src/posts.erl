-module(posts).
-export([index/0, by_id/1]).

index() -> 
    {ok, _Cols, Rows} = blerg_db:equery("SELECT p.id, p.title, u.name AS author, p.created_at, p.body
                                         FROM posts p
                                         JOIN users u ON p.author_id = u.id
                                         ORDER BY p.created_at DESC
                                       LIMIT 10"),
    % We want a proplist, rather than simple columns, so...
    % TODO: Consider iterating over the returned columns and doing it that way...
    [[{id, Id}, {title, Title}, {author, Author}, {created_at, CreatedAt}, {body, Body}]
     || {Id, Title, Author, CreatedAt, Body} <- Rows].

by_id(Id) when is_binary(Id) ->
    by_id(binary_to_list(Id));
by_id(Id) when is_list(Id) ->
    by_id(list_to_integer(Id));
by_id(Id) ->
    {ok, _Cols, [{Id, Title, Author, CreatedAt, Body}]} =
    blerg_db:equery("SELECT p.id, p.title, u.name AS author, p.created_at, p.body
                    FROM posts p
                    JOIN users u ON p.author_id = u.id
                    WHERE p.id = $1", [Id]),
    [{id, Id}, {title, Title}, {author, Author}, {created_at, CreatedAt}, {body, Body}].

