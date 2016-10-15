-module(ae_rest).

-export([run/2]).

-include("ae_records.hrl").


run(UrlTemplate, [H | Rest]) ->
  [run(UrlTemplate, H) | run(UrlTemplate, Rest)];

run(UrlTemplate, {Stage, _Solver} = S) ->
  Url = lists:flatten(io_lib:format(UrlTemplate, [Stage])),
  runStage(Url, S);

run(_UrlTemplate, []) ->
  [].


runStage(Url, {Stage, Solver} = S) when Url =/= null ->
  %%io:format("Url: ~p~n", [Url]),
  {ok, {{_, 200, _}, _, Body}} = httpc:request(Url),
  #{<<"equation">> := Equation} = jiffy:decode(Body, [return_maps]),
  Solutions = Solver(binary_to_list(Equation)),
  Json = jiffy:encode({[{<<"correctedEquations">>, lists:map(fun list_to_binary/1, Solutions)}]}),
  {ok, {{_, 202, _}, _, BodyPost}} = httpc:request(post, {Url, [], "application/json", Json}, [], []),
  JsonResult = jiffy:decode(BodyPost, [return_maps]),
  case JsonResult of
    #{<<"linkToNextTask">> := NextUrlB} ->
      NextUrl = binary_to_list(NextUrlB),
      case string:str(NextUrl, "stage/" ++ integer_to_list(Stage)) > 0 of
        true -> runStage(NextUrl, S);
        false -> runStage(null, S)
      end;
    #{} -> runStage(null, S)
  end;

runStage(null, _Solver) ->
  success.
