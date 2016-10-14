-module(ae_display).

-export([new/1, default/0]).

-include("ae_records.hrl").


new(States) ->
  #display{
    states=States,
    segment_to_value=maps:from_list(lists:map(fun (E) -> {E#state.segment, E#state.value} end, States)),
    value_to_segment=maps:from_list(lists:map(fun (E) -> {E#state.value, E#state.segment} end, States))
  }.


default() ->
  new([?ZERO, ?ONE, ?TWO, ?THREE, ?FOUR, ?FIVE, ?SIX, ?SEVEN, ?EIGHT, ?NINE]).
