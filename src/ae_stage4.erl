-module(ae_stage4).

-export([generate_solutions/3]).

-include("ae_records.hrl").


generate_solutions(#display{} = Display, #term{} = T, FlipMap) ->
  Stage3Solutions = ae_stage3:generate_solutions(Display, T),
  ae_util:deduplicate(lists:flatten([permutate(E, FlipMap) || E <- Stage3Solutions])).


permutate(#term{value=V, left=Left, right=Right} = T, FlipMap) ->
  LPerm = permutate(Left, FlipMap),
  RPerm = permutate(Right, FlipMap),
  [T] ++ [T#term{value=maps:get(V, FlipMap, V), left=L, right=R} || L <- LPerm, R <- RPerm] ++ [T#term{left=L, right=R} || L <- LPerm, R <- RPerm];

permutate(undefined, _FlipMap) ->
  [].
