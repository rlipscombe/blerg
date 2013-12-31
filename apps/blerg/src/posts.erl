-module(posts).
-export([index/0]).

index() -> 
    {ok, _Cols, Rows} = blerg_db:equery("SELECT p.title, u.name AS author, p.created_at, p.body
                                         FROM posts p
                                       JOIN users u ON p.author_id = u.id
                                       ORDER BY p.created_at DESC
                                       LIMIT 10"),
    % We want a proplist, rather than simple columns, so...
    % TODO: Consider iterating over the returned columns and doing it that way...
    [[{title, Title}, {author, Author}, {created_at, CreatedAt}, {body, Body}] || {Title, Author, CreatedAt, Body} <- Rows].

