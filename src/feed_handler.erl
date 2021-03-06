-module(feed_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

-record(state, {opts, base_url, this_url}).

init(_Type, Req, Opts) ->
    Scheme = "http",
    {Host, Req2} = cowboy_req:host(Req),
    {Port, Req3} = cowboy_req:port(Req2),
    {Path, Req4} = cowboy_req:path(Req3),
    State = #state{base_url = create_base_url(Scheme, Host, Port),
                   this_url = create_this_url(Scheme, Host, Port, Path),
                  opts = Opts},
    {ok, Req4, State}.

handle(Req, #state{this_url = ThisUrl, base_url = BaseUrl, opts = Opts} = State) ->
    Site = proplists:get_value(site, Opts),
    Title = proplists:get_value(name, Site),

    Headers = [{<<"content-type">>, <<"application/atom+xml">>}],
    Items = posts:feed(),
    Body = feed(Title, ThisUrl, BaseUrl, Items),
    {ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

create_base_url("http", Host, 80) ->
    "http://" ++ binary_to_list(Host);
create_base_url("https", Host, 443) ->
    "https://" ++ binary_to_list(Host);
create_base_url(Scheme, Host, Port) ->
    Scheme ++ "://" ++ binary_to_list(Host) ++ ":" ++ integer_to_list(Port).

create_this_url(Scheme, Host, Port, Path) ->
    create_base_url(Scheme, Host, Port) ++ Path.

feed(Title, Link, BaseUrl, Items) ->
    UpdatedAt = get_updated_at(Items),
    FeedDetails = [{title, [], [Title]},
                   {link, [{href, Link}, {rel, "self"}], []},
                   {updated, [], [binary_to_list(iso8601:format(UpdatedAt))]},
                   {id, [], [Link]}],
    FeedItems = [transform_item(BaseUrl, I) || I <- Items],
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

transform_item(BaseUrl, I) ->
    Id = proplists:get_value(id, I),
    Title = binary_to_list(proplists:get_value(title, I)),
    Slug = binary_to_list(proplists:get_value(slug, I)),
    Body = proplists:get_value(body, I),
    CreatedAt = proplists:get_value(created_at, I),
    Updated = binary_to_list(iso8601:format(CreatedAt)),
    Link = [BaseUrl, "/post/", integer_to_list(Id), "/", Slug],
    Content = "<div>" ++ markdown:conv(binary_to_list(Body)) ++ "</div>",
    {entry, [], [
                {title, [], [Title]},
                {updated, [], [Updated]},
                {author, [], [{name, ["Roger Lipscombe"]}]},
                {link, [{href, Link}], []},
                {id, [], [Link]},
                {content, [{type, "html"}], [Content]}
               ]}.
