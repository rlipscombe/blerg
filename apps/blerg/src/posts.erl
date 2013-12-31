-module(posts).
-export([index/0]).

index() ->
    [[{title, "Hello"}, {author, "roger"}, {body, "Meh"}],
     [{title, "World"}, {author, "roger"}, {body, "Feh"}]].

