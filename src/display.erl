-module(display).

-export([new/1, default/0, get_states/2]).

-include("records.hrl").


new(States) ->
  #display{
    states=States,
    segment_to_value=maps:from_list(lists:map(fun (E) -> {E#state.segment, E#state.value} end, States)),
    value_to_segment=maps:from_list(lists:map(fun (E) -> {E#state.value, E#state.segment} end, States))
  }.


get_states(Segments, #display{segment_to_value=SV}) when is_list(Segments) ->
  lists:filtermap(fun(E) ->
    case maps:is_key(E, SV) of
      true -> {true,  #state{value=maps:get(E, SV), segment=E}};
      false -> false
    end end, Segments).


default() ->
  new([?ZERO, ?ONE, ?TWO, ?THREE, ?FOUR, ?FIVE, ?SIX, ?SEVEN, ?EIGHT, ?NINE]).
