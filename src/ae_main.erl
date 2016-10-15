-module(ae_main).

-export([start/0, start/1]).

-include("ae_records.hrl").


start() ->
  start([]).

start(_Args) ->
  Display = ae_display:default(),
  Operators = [
    {plus, "+", fun(L, R) -> ae_state:plus(Display, L, R) end},
    {minus, "-", fun(L, R) -> ae_state:minus(Display, L, R) end},
    {equals, "=", fun(L, R) -> L#state.value == R#state.value end}
  ],
  FunStringMapping = maps:from_list([{Fun, Str} || {_Atom, Str, Fun} <- Operators]),
  ToString =
    fun(T, E) ->
      case T of
        op -> maps:get(E, FunStringMapping);
        value -> integer_to_list(E#state.value)
      end
    end,
  ParseMapping = maps:put(
    convert, fun(E) -> ae_state:from_string(Display, E) end,
    maps:from_list([{Atom, Fun} || {Atom, _Str, Fun} <- Operators])
  ),
  Term = ae_term:parse("0=9", ParseMapping),
  %%io:format("Term: ~p ~n", [Term]),
  Solutions = lists:filter(fun ae_term:evaluate/1, ae_stage1:generate_solutions(Display, Term)),
  io:format("Stage1: ~p ~n", [ae_term:to_string(Term, ToString)]),
  lists:foreach(fun(E) -> io:format(" * ~p~n", [ae_term:to_string(E, ToString)]) end, Solutions),
  io:format("~n~n~n~n~n"),
  exit(error).
