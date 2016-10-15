-module(ae_main).

-export([start/0, start/1]).

-include("ae_records.hrl").


make_solver(ParseMapping, ToString, Fun) ->
  fun(Equation) ->
    Term = ae_term:parse(Equation, ParseMapping),
    Solutions = Fun(Term),
    ValidSolutions = lists:filter(fun ae_term:evaluate/1, Solutions),
    ae_util:deduplicate([ae_term:to_string(E, ToString) || E <- ValidSolutions])
  end.


start() ->
  start([]).

start(_Args) ->
  inets:start(),
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
  Stage4FlipMap = #{
    maps:get(minus, ParseMapping) => maps:get(plus, ParseMapping),
    maps:get(plus, ParseMapping) => maps:get(minus, ParseMapping)
  },
  Stage1And2Solver = make_solver(ParseMapping, ToString, fun(Term) -> ae_stage1:generate_solutions(Display, Term) end),
  Stage3Solver = make_solver(ParseMapping, ToString, fun(Term) -> ae_stage3:generate_solutions(Display, Term) end),
  Stage4Solver = make_solver(ParseMapping, ToString, fun(Term) -> ae_stage4:generate_solutions(Display, Term, Stage4FlipMap) end),
  R = ae_rest:run(
    "http://localhost:8080/assignment/stage/~B/testcase/1",
    [{1, Stage1And2Solver}, {2, Stage1And2Solver}, {3, Stage3Solver}, {4, Stage4Solver}]
  ),
  %R = test(Display, ParseMapping, ToString),
  io:format("R: ~p~n", [R]),
  io:format("~n~n~n~n~n"),
  exit(error).


test(Display, ParseMapping, ToString) ->
  Term = ae_term:parse("0+0=9", ParseMapping),
  Solutions = ae_stage4:generate_solutions(Display, Term, #{
    maps:get(minus, ParseMapping) => maps:get(plus, ParseMapping),
    maps:get(plus, ParseMapping) => maps:get(minus, ParseMapping)
  }),
  io:format("Plus: ~p~nMinus: ~p~n", [maps:get(plus, ParseMapping), maps:get(minus, ParseMapping)]),
  lists:foreach(fun(E) -> io:format("-> ~p~n", [ae_term:to_string(E, ToString)]) end, Solutions).