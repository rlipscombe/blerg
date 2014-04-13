-module(blerg_util).
-export([ensure_started/1, ensure_all_started/1]).

ensure_started(Application) ->
    ensure_all_started([Application]).

ensure_all_started(Applications) ->
    % Note: application:ensure_all_started requires Erlang R16B02;
    % homebrew (on OSX) only has R16B01, so we have to do this...
    [ ok = ensure_all_started(A, permanent) || A <- Applications],
    ok.

ensure_all_started(App, Type) ->
    ensure_all_started(App, Type, application:start(App)).

ensure_all_started(_App, _Type, ok) ->
    ok;
ensure_all_started(_App, _Type, {error, {already_started, _App}}) ->
    ok;
ensure_all_started(App, Type, {error, {not_started, Dep}}) ->
    ok = ensure_all_started(Dep, Type),
    ensure_all_started(App, Type);
ensure_all_started(App, _Type, {error, Reason}) ->
    erlang:error({app_start_failed, App, Reason}).

