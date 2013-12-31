-module(posts).
-export([index/0]).

index() -> 
    {ok, _Cols, Rows} = blerg_db:equery("SELECT p.title, u.name AS author, p.body
                                         FROM posts p
                                       JOIN users u ON p.author_id = u.id"),
    % We want a proplist, rather than simple columns, so...
    % TODO: Consider iterating over the returned columns and doing it that way...
    [[{title, Title}, {author, Author}, {body, Body}] || {Title, Author, Body} <- Rows].

