-module(index_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, Opts) ->
    State = Opts,
    {ok, Req, State}.

handle(Req, State) ->
    Site = proplists:get_value(site, State),
    Title = proplists:get_value(title, Site),
    {User, Req2} = cowboy_req:meta(user, Req),

    Headers = [{<<"content-type">>, <<"text/html">>}],
    Ps = folsom_metrics:histogram_timed_update({index_handler, posts, index},
                                               fun() -> posts:index() end),
    Posts = folsom_metrics:histogram_timed_update({index_handler, posts, transform},
                                                  fun() -> [transform:post(P) || P <- Ps] end),
    {ok, Body} = render([{site, Site}, {title, Title}, {posts, Posts}, {user, User}]),
    {ok, Req3} = cowboy_req:reply(200, Headers, Body, Req2),
    {ok, Req3, State}.

render(Params) ->
    folsom_metrics:histogram_timed_update(
      {blerg, render, index_dtl},
      fun() ->
              index_dtl:render(Params)
      end).

terminate(_Reason, _Req, _State) ->
    ok.
