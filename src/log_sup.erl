-module(log_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
  ChildSpecs = [#{id => log_generator,
                  start => {random_log_generator, generate, []},
                  restart => permanent,
                  shutdown => brutal_kill}],
  {ok, {SupFlags, ChildSpecs}}.

