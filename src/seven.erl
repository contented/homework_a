-module(seven).
-compile(export_all).

collatz(N) ->
    application:set_env(homework_a, max_num_of_workers, 5),
    S = self(),
    Pid = spawn(fun() -> pool(S, N) end),
    receive
	{Pid, Result} ->
	    Result
    end.

count_sequence(Pid, N) ->
    Pid ! sequence(N, {0, N}).

sequence(1, {Count, Start}) ->
    {Count, Start};
sequence(N, {Count, Start}) ->
    NextStep = case N rem 2 of
        0 -> N div 2;
        1 -> 3 * N + 1
    end,
    sequence(NextStep, {Count + 1, Start}).

pool(Parent, Length) ->
    process_flag(trap_exit, true),
    Integers = lists:seq(1, Length),
    {ok, MaxWorkers} = application:get_env(homework_a, max_num_of_workers),
    { StartingIntegers, IntegersToDo } = lists:split(MaxWorkers, Integers),
    lists:foreach(fun(I) -> start_worker(self(), I) end, StartingIntegers),
    {Chain, Number} = collect(Length, {1,1}, IntegersToDo),
    Parent ! {self(), {{number, Number}, {chain, Chain}}}.

start_worker(PoolPid,I) ->
    spawn_link(fun() -> count_sequence(PoolPid, I) end).

collect(0, {K,V}, _IntegersToDo) ->
    {K,V};
collect(N, {K,V}, IntegersToDo) ->
    receive
    {Key, Val} ->
        if  Key > K -> collect(N, {Key, Val}, IntegersToDo);
            true    -> collect(N, {K,V}, IntegersToDo)
        end;    
    {'EXIT', _,  _Why} ->
        case IntegersToDo of
            [] ->   collect(N-1, {K,V}, IntegersToDo);
            _ ->    start_worker(self(), hd(IntegersToDo)),
                    collect(N-1, {K,V}, tl(IntegersToDo))
        end
    end.
