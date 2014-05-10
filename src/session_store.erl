-module(session_store).
-export([new_session/1, get_session/1]).
-export([start_link/0]).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_info/2, handle_cast/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(TABLE, ?MODULE).

new_session(Data) ->
    Bytes = crypto:rand_bytes(16),
    SessionId = list_to_binary(lists:flatten([io_lib:format("~2.16.0B", [X]) || <<X:8>> <= Bytes])),

    gen_server:call(?SERVER, {put, SessionId, Data}),

    {ok, SessionId}.

get_session(SessionId) ->
    case ets:lookup(?TABLE, SessionId) of
        [] -> undefined;
        [{SessionId, Data}] -> Data
    end.

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    ?TABLE = ets:new(?TABLE, [set, protected, named_table]),
    State = undefined,
    {ok, State}.

handle_call({put, SessionId, Data}, _From, State) ->
    ets:insert(?TABLE, {SessionId, Data}),
    {reply, ok, State};
handle_call(_Req, _From, State) ->
    {reply, ok, State}.

handle_info(_Info, State) ->
    {noreply, State}.

handle_cast(_Req, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
