-module(ae_state).

-export([from_string/2, plus/3, minus/3, valid_from_segments/2, permutate/3]).

-include("ae_records.hrl").


from_string(#display{value_to_segment=VS}, Str) ->
  Value = element(1, string:to_integer(Str)),
  %%io:format("Value: ~p -> ~p ~n", [Str, Value]),
  #state{value=Value, segment=maps:get(Value, VS)}.


plus(#display{value_to_segment=VS}, L, R) ->
  Result = L#state.value + R#state.value,
  #state{value=Result, segment=maps:get(Result, VS, invalid)}.


minus(#display{value_to_segment=VS}, L, R) ->
  Result = L#state.value - R#state.value,
  #state{value=Result, segment=maps:get(Result, VS, invalid)}.


valid_from_segments(#display{segment_to_value=SV}, Segments) when is_list(Segments) ->
  lists:filtermap(fun(E) ->
    case maps:is_key(E, SV) of
      true -> {true,  #state{value=maps:get(E, SV), segment=E}};
      false -> false
    end end, Segments).


permutate(Operation_s, #display{} = Display, #state{segment=Segment}) ->
  valid_from_segments(Display, ae_segment:permutate(Operation_s, Segment));

permutate([Operation | Rest], Display, States) when is_list(States) ->
  permutate(Rest, Display, ae_util:deduplicate(lists:flatten(
    lists:map(fun(E) -> permutate(Operation, Display, E) end, States)
  )));

permutate([], _, States) ->
  States.
