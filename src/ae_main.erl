-module(ae_main).

-export([start/0, start/1]).

-include("ae_records.hrl").


start() ->
  start([]).

start(_Args) ->
  Display = ae_display:default(),
  Term = ae_term:parse("0=9", #{
    convert => fun(E) -> ae_state:from_string(Display, E) end,
    plus => fun(L, R) -> ae_state:plus(Display, L, R) end,
    minus => fun(L, R) -> ae_state:minus(Display, L, R) end,
    equals => fun(L, R) -> L#state.value == R#state.value end
  }),
  %%io:format("Term: ~p ~n", [Term]),
  Result = ae_term:evaluate(Term),
  io:format("Result: ~p ~n", [Result]),
  exit(error).
