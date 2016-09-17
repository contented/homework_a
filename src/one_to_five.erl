-module(one_to_five).
-compile([export_all]).

% 1

sum_of_multiples() -> 
	Number = 1000 - 1,
	sum_arithmetic_series(3,Number) + sum_arithmetic_series(5,Number) - sum_arithmetic_series(15,Number).

sum_arithmetic_series(Step, Max) -> 
	Number = Max div Step, 
	Step * Number * (Number + 1) div 2.

% 2

fibo(Max) ->
	fibo(2, 1, Max, 2).
fibo(Last, SecondLast, Max, Acc) when Last + SecondLast =< Max ->
	Next = Last + SecondLast,
	NextAcc = case Next rem 2 of
		0 -> Acc + Next;
		1 -> Acc
	end,
	fibo(Next, Last, Max, NextAcc);
fibo(_Last, _SecondLast, _Max, Acc) ->
	Acc.

% 3

max_prime() ->
	max_prime(600851475143, 2).
max_prime(N, I) when I * I < N ->
	NReduced = zero_remainder_division(N, I),
	max_prime(NReduced, I + 1);
max_prime(N, _I) ->
	N.

zero_remainder_division(N, I) when (N rem I) == 0 ->
	zero_remainder_division(N div I, I);
zero_remainder_division(N, _I) ->
	N.

% 4

traverse_diagonally(Size) ->
	NumberOfDiagonals = Size * 2 - 1,
	Answer = 0,
	traverse_diagonally(Size, NumberOfDiagonals, Answer).

traverse_diagonally(N, Slice, Answer) when Slice > 0, Answer == 0 ->
	Z = case Slice < N of
		false -> Slice - N;
		true -> 0
	end,
	FoundPalindromes = [J * (Slice - J + 1) || J <- lists:seq(Z + 1, Slice - Z), is_palindrome(J * (Slice - J + 1))],
	NextAnswer = lists:max([Answer | FoundPalindromes]),
	traverse_diagonally(N, Slice - 1, NextAnswer);
traverse_diagonally(_N, _I, Answer) ->
	Answer.

is_palindrome(Int) ->
	Int == list_to_integer(lists:reverse(integer_to_list(Int))).

% 5
 
gcd(A, 0) -> 
	A;
 gcd(A, B) -> 
	gcd(B, A rem B).
 
lcm(A,B) ->
	abs(A*B div gcd(A,B)).

solution(List) ->
	lists:foldl(
		fun(I, Acc) -> lcm(I, Acc) end,
		1,
		List).


