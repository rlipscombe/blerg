-module(tag_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),
    {User, Req2} = cowboy_req:meta(user, Req),

    {Tag, Req3} = cowboy_req:binding(tag, Req2),
    Title = "Posts tagged '" ++ binary_to_list(Tag) ++ "'",
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = [transform:post(P, [teaser]) || P <- posts:tagged(Tag)],
    {ok, Body} = case Posts of
        [] -> tag_unknown_dtl:render([{title, Title}, {site, Site}, {tag, Tag}, {user, User}]);
        _ -> tag_dtl:render([{title, Title}, {site, Site}, {posts, Posts}, {user, User}])
    end,
    {ok, Req4} = cowboy_req:reply(200, Headers, Body, Req3),
    {ok, Req4, State}.

terminate(_Reason, _Req, _State) ->
    ok.
