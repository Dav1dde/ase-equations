-module(ae_stage3).

-export([generate_solutions/2]).

-include("ae_records.hrl").


generate_solutions(#display{} = Display, #term{} = T) ->
  E = ae_term:extract(value, T),
  Stage1Solutions = ae_stage1:generate_solutions(Display, T),
  Solutions = permutate([remove, add], Display, E) ++ permutate([add, remove], Display, E),
  lists:map(fun(E) -> ae_term:replace(value, T, E) end, Solutions) ++ Stage1Solutions.


permutate([Operation | RestOp] = O, #display{} = D, [H | Rest] = L) ->
  case length(O) > length(L) of
    true -> [];
    false ->
      %% original
      [[H | R] || R <- permutate(O, D, Rest)] ++
      %% permutated
      [[E | R] || E <- ae_state:permutate([Operation], D, H), R <- permutate(RestOp, D, Rest)]
  end;

permutate([_Op | _RestOperations], _D, []) ->
  [];

permutate([], _D, L) ->
  [L].
