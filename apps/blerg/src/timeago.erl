-module(timeago).
-export([in_words/1]).

%% @doc Format {{Y,M,D},{H,m,s}} as (e.g.) "17 minutes ago".
in_words({{_,_,_},{_,_,_}} = DateTime) ->
    Then = datetime_to_epoch_seconds(truncate_datetime_seconds(DateTime)),
    Now = now_to_epoch_seconds(os:timestamp()),
    DistanceSecs = Now - Then,
    seconds_in_words(DistanceSecs) ++ " ago".

%% Given a {{Y,M,D},{H,m,s}} tuple, return the seconds since the Unix epoch.
datetime_to_epoch_seconds(DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime) -
    calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}}).

%% os:timestamp() and now() return {Me,Se,Mi} since the Unix epoch.
now_to_epoch_seconds({Me,Se,_}) ->
    (Me * 1000 * 1000) + Se.

%% datetime_to_gregorian_seconds can't deal with fractional seconds; epgsql (for
%% example) returns fractional seconds; so truncate the seconds.
truncate_datetime_seconds({{Ye,Mo,Da},{Ho,Mi,Se}}) ->
    {{Ye,Mo,Da},{Ho,Mi,trunc(Se)}}.

%% The logic from here down is basically lifted from https://github.com/ecto/node-timeago
seconds_in_words(Secs) when Secs < 45 ->
    integer_to_list(Secs) ++ " seconds";
seconds_in_words(Secs) when Secs < 90 ->
    "1 minute";
seconds_in_words(Secs) ->
    minutes_in_words(trunc(Secs / 60)).

minutes_in_words(M) when M < 45 ->
    integer_to_list(M) ++ " minutes";
minutes_in_words(M) when M < 90 ->
    "1 hour";
minutes_in_words(M) ->
    hours_in_words(trunc(M / 60)).

hours_in_words(H) when H < 24 ->
    integer_to_list(H) ++ " hours";
hours_in_words(H) when H < 48 ->
    "1 day";
hours_in_words(H) ->
    days_in_words(trunc(H / 24)).

days_in_words(D) when D < 30 ->
    integer_to_list(D) ++ " days";
days_in_words(D) when D < 60 ->
    "1 month";
days_in_words(D) when D < 365 ->
    integer_to_list(trunc(D / 30)) ++ " months";
days_in_words(D) ->
    years_in_words(D / 365).

years_in_words(Y) when Y < 2 ->
    "1 year";
years_in_words(Y) ->
    integer_to_list(trunc(Y)) ++ " years".


