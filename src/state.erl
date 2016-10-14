-module(state).

-export([permutate/3]).

-include("records.hrl").


permutate(Operation, #display{segment_to_value=SV}, #state{segment=Segment}) when not is_list(Operation) ->
  [Record | Data] = tuple_to_list(Segment),
  lists:filtermap(fun(E) ->
    ESegment = list_to_tuple([Record | E]),
    case maps:is_key(ESegment, SV) of
      true -> {true, #state{value=maps:get(ESegment, SV), segment=ESegment}};
      false -> false
    end end, segment:permutate(Operation, Data));

permutate([Operation | Rest], Display, State) when not is_list(State) ->
  permutate(Rest, Display, permutate(Operation, Display, State));

permutate([Operation | Rest], Display, States) when is_list(States) ->
  permutate(Rest, Display, util:deduplicate(lists:flatten(
    lists:map(fun(E) -> permutate(Operation, Display, E) end, States)
  )));

permutate([], _, States) ->
  States.
