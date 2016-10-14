-module(ae_util).

-export([deduplicate/1]).


deduplicate(L) ->
  sets:to_list(sets:from_list(L)).
