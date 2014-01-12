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
    Headers = [{<<"content-type">>, <<"application/rss+xml">>}],
    Body = feed(),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

feed() ->
    Title = "Roger's Blog",
    Link = "http://localhost:4000/feed",
    Description = Title,
    Items = posts:feed(),
    feed(Title, Link, Description, Items).

feed(Title, Link, Description, Items) ->
    ChannelDetails = [{title, [], [Title]},
                      {link, [], [Link]},
                      {description, [], [Description]}
                      % TODO: pubDate, lastBuildDate?
                      % TODO: image?
                     ],
    ChannelItems = [transform_item(I) || I <- Items],
    Feed = [{rss, [{version, "2.0"}],
             [{channel, [], ChannelDetails ++ ChannelItems}]}],

    Prolog = [],
    Xml = xmerl:export_simple(Feed, xmerl_xml, Prolog),
    unicode:characters_to_binary(Xml).

transform_item(I) ->
    Title = binary_to_list(proplists:get_value(title, I)),
    PubDate = ec_date:format("r", proplists:get_value(created_at, I)),
    {item, [], [
                {title, [], [Title]},
                {pubDate, [], [PubDate]}]}.

%    Id = proplists:get_value(id, I),
%    Link = "http://localhost:4000/post/" ++ Id,
%    Teaser = proplists:get_value(body, I),
%    PubDate = proplists:get_value(created_at, I),
%    {item, [], [
%                {title, [], [Title]},
%                {link, [], [Link]},
%                {description, [], [Teaser]},
%                {pubDate, [], [PubDate]},
%                {guid, [], [Link]}]}.

