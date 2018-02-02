-module(random_log_generator).

-export([generate/0]).

generate() ->
  case rand:uniform(3) of
    1 -> lager:info("nothing special");
    2 -> lager:warning("this worries me");
    3 -> lager:error("somethig is really wrong")
  end,
  timer:sleep(rand:uniform(5000)),
  generate().
