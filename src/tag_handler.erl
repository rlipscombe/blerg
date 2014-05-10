-module(tag_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    {ok, Req, Opts}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),

    {Tag, Req2} = cowboy_req:binding(tag, Req),
    Title = "Posts tagged '" ++ binary_to_list(Tag) ++ "'",
    Headers = [{<<"content-type">>, <<"text/html">>}],
    Posts = [transform:post(P) || P <- posts:tagged(Tag)],
    {ok, Body} = case Posts of
        [] -> tag_unknown_dtl:render([{title, Title}, {site, Site}, {tag, Tag}]);
        _ -> tag_dtl:render([{title, Title}, {site, Site}, {posts, Posts}])
    end,
    {ok, Req3} = cowboy_req:reply(200, Headers, Body, Req2),
    {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
    ok.
