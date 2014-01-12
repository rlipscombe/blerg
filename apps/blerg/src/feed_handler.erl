-module(feed_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).
-export([feed/0]).

init(_Type, Req, _Opts) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    %Title = "Roger's Blog",
    %{ok, Rev} = application:get_key(blerg, vsn),
    %Site = [{name, "Roger's Blog"}, {rev, Rev}],
    %Headers = [{<<"content-type">>, <<"application/atom+xml">>}],
    Headers = [{<<"content-type">>, <<"text/xml">>}],
    Body = feed(),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

feed() ->
    Title = "Roger's Blog",
    Link = "http://localhost:4000/feed",
    Items = posts:feed(),
    feed(Title, Link, Items).

feed(Title, Link, Items) ->
    UpdatedAt = get_updated_at(Items),
    FeedDetails = [{title, [], [Title]},
                   {link, [{href, Link}], []},
                   {updated, [], [binary_to_list(iso8601:format(UpdatedAt))]}],
    FeedItems = [transform_item(I) || I <- Items],
    Feed = [{feed, [{xmlns, "http://www.w3.org/2005/Atom"}],
             FeedDetails ++ FeedItems}],

    Prolog = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>"],
    Xml = xmerl:export_simple(Feed, xmerl_xml, [{prolog, Prolog}]),
    unicode:characters_to_binary(Xml).

% @todo This needs testing properly with no DB entries.
get_updated_at([]) ->
    os:timestamp();
get_updated_at([H|_]) ->
    proplists:get_value(created_at, H).

transform_item(I) ->
    Id = proplists:get_value(id, I),
    Title = binary_to_list(proplists:get_value(title, I)),
    CreatedAt = proplists:get_value(created_at, I),
    Updated = binary_to_list(iso8601:format(CreatedAt)),
    Link = "http://localhost:4000/post/" ++ integer_to_list(Id),
    {item, [], [
                {title, [], [Title]},
                {updated, [], [Updated]},
                {link, [{href, Link}], []}
               ]}.
%    Teaser = proplists:get_value(body, I),

