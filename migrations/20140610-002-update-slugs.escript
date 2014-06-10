#!/usr/bin/env escript

main([]) ->
    add_pathz("deps/epgsql/ebin"),
    {ok, C} = pgsql:connect("localhost", "blerg", "", [{database, "blerg"}]),
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, title FROM posts"),
    update_slugs(C, Rows),
    ok.

update_slugs(_C, []) ->
    ok;
update_slugs(C, [{Id, Title}|Posts]) ->
    io:format("~p: ~p", [Id, Title]),
    Slug = create_slug(Title),
    io:format(" -> ~p\n", [Slug]),
    pgsql:equery(C, "UPDATE posts SET slug = $1 WHERE id = $2", [Slug, Id]),
    update_slugs(C, Posts).

create_slug(Title) ->
    list_to_binary(string:to_lower(re:replace(Title, "[^A-Za-z0-9]{1,}", "-", [global, {return, list}]))).

add_pathz(Path) ->
    add_pathz(Path, 2).

add_pathz(Path, Depth) ->
    add_pathz_if(filelib:is_dir(Path), Path, Depth).

add_pathz_if(true, Path, _) ->
    code:add_pathz(filename:absname(Path));
add_pathz_if(false, _Path, 0) ->
    {error, not_found};
add_pathz_if(false, Path, Depth) ->
    add_pathz(filename:join("..", Path), Depth - 1).

%% -*- erlang -*-
%% vim: ft=erlang
