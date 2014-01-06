-module(aliases).
-export([search/1]).

search(Path) ->
    lager:debug("Looking for alias ~p", [Path]),
    {ok, _Cols, Rows} = blerg_db:equery("SELECT a.post_id
                                         FROM aliases a
                                        WHERE a.alias = $1", [Path]),
    case Rows of
        [{Id}] ->
            Url = "/post/" ++ integer_to_list(Id),
            {ok, Url};
        [] ->
            {error, not_found}
    end.

