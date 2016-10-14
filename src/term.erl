-module(term).

-export([evaluate/1, parse/2]).

-include("records.hrl").


evaluate(#term{type=op, value=OP, left=L, right=R}) ->
  OP(evaluate(L), evaluate(R));

evaluate(#term{type=value, value=V}) ->
  V.


parse(Str, #{} = Map) ->
  Tokens = tokenize(Str),
  build_term(Tokens, Map).


build_term([H | Tokens], #{} = Map) ->
  %%io:format("Tokens: ~p ~n", [[H | Tokens]]),
  build_term([H | Tokens], Map, #term{}).

build_term([H | Tail], #{convert := C, plus := P, minus := M, equals := E} = Map, #term{} = T) ->
  case Tail == [] of
    true ->
      %%io:format("Last ~p ~n", [H]),
      #term{type=value, value=C(element(1, string:to_integer(H)))};
    false ->
      [Next | Rest] = Tail,
      %%io:format("~p -> ~p -> ~p | ~p ~n", [H, Next, Rest, T]),
      if
        H == "+"-> build_term(Rest, Map, #term{type=op, value=P, left=T, right=build_term([Next], Map, #term{})});
        H == "-"-> build_term(Rest, Map, #term{type=op, value=M, left=T, right=build_term([Next], Map, #term{})});
        H == "="-> #term{type=op, value=E, left=T, right=build_term(Tail, Map, #term{})};
        true -> build_term(Tail, Map, #term{type=value, value=C(element(1, string:to_integer(H)))})
      end
  end;

build_term([], _, #term{} = T) ->
  T.

tokenize([Char | Rest]) ->
  if
    [Char] == " " -> [];
    true -> [[Char]]
  end ++ tokenize(Rest);

tokenize([]) -> [].