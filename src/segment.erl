-module(segment).

-export([permutate/2]).

-include("records.hrl").


permutate(Operation, Segment) when is_tuple(Segment) ->
  [Head | Data] = tuple_to_list(Segment),
  if
    is_atom(Head) -> lists:map(fun list_to_tuple/1, [[Head|T] || T <- permutate(Operation, Data)]);
    true -> lists:map(fun list_to_tuple/1, permutate(Operation, [Head | Data]))
  end;

permutate(Operation, []) when Operation == add; Operation == remove ->
  [];

permutate(Operation, [Head | Rest]) when Operation == add; Operation == remove ->
  %% remove duplicates
  util:deduplicate(
    %% flip head bit
    [[flip(Operation, Head) | Rest]] ++
    %% keep head bit, but flip all other bits
    [[Head | T] || T <- permutate(Operation, Rest)]
  %% remove starting list, because we need to at least flip one bit
  ) -- [[Head | Rest]].


flip(add, on) -> on;
flip(add, off) -> on;
flip(remove, on) -> off;
flip(remove, off) -> off.