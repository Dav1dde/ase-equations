-module(ae_stage1).

-export([generate_solutions/2]).

-include("ae_records.hrl").


generate_solutions(#display{} = Display, #term{} = T) ->
  E = ae_term:extract(value, T),
  ae_util:deduplicate([T] ++ lists:map(fun(E) -> ae_term:replace(value, T, E) end, permutate(Display, E))).


permutate(#display{} = D, [H | Rest]) ->
  %% permutate the first value
  lists:map(fun(E) -> [E | Rest] end, ae_state:permutate([add, remove], D, H)) ++
  %% permutate the other values and keep the first the same
  lists:map(fun(E) -> [H | E] end, permutate(D, Rest));

permutate(_D, []) ->
  [].


%%permutate(#display{} = D, #term{type=op, value=V, left=L, right=R} = T) ->
%%  #term{type=op, value=V, left=permutate(D, L), right=permutate(D, R)};

%%permutate(#display{} = D, #term{type=value, value=V} = T) ->
%%  T#term{value=ae_util:deduplicate([V] ++ ae_state:permutate([add, remove], D, V))}.