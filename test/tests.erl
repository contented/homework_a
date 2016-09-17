-module(tests).
-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

first_test() ->
	?assertEqual(233168, one_to_five:sum_of_multiples()).

second_test() ->
	?assertEqual(4613732, one_to_five:fibo(4000000)).

third_test() ->
	?assertEqual(6857, one_to_five:max_prime()).

fourth_test() ->
	?assertEqual(9009, one_to_five:traverse_diagonally(100)).

fifth_test() ->
	?assertEqual(232792560, one_to_five:solution(lists:seq(2,20))).

seventh_test_() ->
         {timeout, 60,
          fun() ->     
			%?assertEqual({{number,837799},{chain,524}}, seven:collatz(1000000)),
			?assertEqual({{number,871},{chain,178}}, seven:collatz(1000))
          end}.

eigth_test() ->
	?assertEqual(ok, gtin14:validate({gtin, <<0,0,0,1,2,3,4,5,6,7,8,9,0,5>>})),
	?assertMatch({error, _}, gtin14:validate({gtin, <<0,0,0,1,2,3,4,5,6,7,8,9,0,6>>})).