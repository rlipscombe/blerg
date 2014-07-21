-module(blerg_db_worker).
-export([start_link/1]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    Hostname = proplists:get_value(hostname, Args),
    Username = proplists:get_value(username, Args),
    Password = proplists:get_value(password, Args),
    Database = proplists:get_value(database, Args),
    {ok, Conn} = pgsql:connect(Hostname, Username, Password, [{database, Database}]),
    {ok, Conn}.

handle_call({equery, Stmt, Params}, _From, Conn) ->
    {reply, pgsql:equery(Conn, Stmt, Params), Conn};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, Conn) ->
    pgsql:close(Conn).

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

