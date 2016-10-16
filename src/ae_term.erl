-module(ae_term).

-export([evaluate/1, to_list/2, extract/2, replace/3, parse/2]).

-include("ae_records.hrl").


evaluate(#term{type=op, value=OP, left=L, right=R}) ->
  %%io:format("evaluate: ~p ~p ~p ~n", [OP, L, R]),
  OP(evaluate(L), evaluate(R));

evaluate(#term{type=value, value=V}) ->
  V.


to_list(#term{type=T, value=V, left=L, right=R}, Fun) ->
  to_list(L, Fun) ++ Fun(T, V) ++ to_list(R, Fun);

to_list(undefined, _Fun) ->
  [].


extract(What, #term{type=T, value=V, left=L, right=R}) ->
  if
    What == T -> extract(What, L) ++ [V] ++ extract(What, R);
    true -> extract(What, L) ++ extract(What, R)
  end;

extract(_What, undefined) -> [].


replace(What, #term{} = Term, With) ->
  element(2, replace2(What, Term, With)).

replace2(What, #term{type=T, left=L, right=R} = Term, [With | Rest]) ->
  if
    What == T ->
      {LeftRest, NewLeft} = replace2(What, L, Rest),
      {RightRest, NewRight} = replace2(What, R, LeftRest),
      {RightRest, Term#term{value=With, left=NewLeft, right=NewRight}};
    true ->
      {LeftRest, NewLeft} = replace2(What, L, [With | Rest]),
      {RightRest, NewRight} = replace2(What, R, LeftRest),
      {RightRest, Term#term{left=NewLeft, right=NewRight}}
      %%Term#term{left=replace(What, L, [With | Rest]), right=replace(What, R, [With | Rest])}
  end;

replace2(_What, Term, []) ->
  {[], Term};

replace2(_What, undefined, With) ->
  {With, undefined}.


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
      #term{type=value, value=C(H)};
    false ->
      [Next | Rest] = Tail,
      %%io:format("~p -> ~p -> ~p | ~p ~n", [H, Next, Rest, T]),
      if
        H == "+"-> build_term(Rest, Map, #term{type=op, value=P, left=T, right=build_term([Next], Map, #term{})});
        H == "-"-> build_term(Rest, Map, #term{type=op, value=M, left=T, right=build_term([Next], Map, #term{})});
        H == "="-> #term{type=op, value=E, left=T, right=build_term(Tail, Map, #term{})};
        true -> build_term(Tail, Map, #term{type=value, value=C(H)})
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