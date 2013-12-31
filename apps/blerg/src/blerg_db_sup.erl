-module(blerg_db_sup).
-export([start_link/0]).
-behaviour(supervisor).
-export([init/1]).

-define(POOL_NAME, blerg_db).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    PoolArgs = [{name, {local, ?POOL_NAME}},
                {worker_module, blerg_db_worker},
                {size, 10},
                {max_overflow, 10}],
    WorkerArgs = [{hostname, "localhost"},
                  {database, "blerg"},
                  {username, "blerg"},
                  {password, ""}],
    PoolSpec = poolboy:child_spec(?POOL_NAME, PoolArgs, WorkerArgs),
    ChildSpecs = [PoolSpec],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.
