-module(state).

-export([valid_from_segments/2, permutate/3]).

-include("records.hrl").


valid_from_segments(#display{segment_to_value=SV}, Segments) when is_list(Segments) ->
  lists:filtermap(fun(E) ->
    case maps:is_key(E, SV) of
      true -> {true,  #state{value=maps:get(E, SV), segment=E}};
      false -> false
    end end, Segments).


permutate(Operation_s, #display{} = Display, #state{segment=Segment}) ->
  valid_from_segments(Display, segment:permutate(Operation_s, Segment));

permutate([Operation | Rest], Display, States) when is_list(States) ->
  permutate(Rest, Display, util:deduplicate(lists:flatten(
    lists:map(fun(E) -> permutate(Operation, Display, E) end, States)
  )));

permutate([], _, States) ->
  States.
