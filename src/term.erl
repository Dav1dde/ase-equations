-module(term).

-export([evaluate/1, plus/2, minus/2]).

-include("records.hrl").


evaluate(#term{type=op, value=OP, left=L, right=R}) ->
  OP(evaluate(L), evaluate(R));

evaluate(#term{type=value, value=V}) ->
  V.



plus(L, R) ->
  L + R.

minus(L, R) ->
  L - R.
