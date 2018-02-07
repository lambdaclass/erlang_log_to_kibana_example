-module(random_log_generator).

-export([generate/0]).

generate() ->
  case rand:uniform(5) of
    1 -> lager:info("nothing special");
    2 -> lager:warning("this worries me");
    3 -> lager:warning("other warning");
    4 -> lager:warning("warning!");
    5 -> lager:error("somethig is really wrong")
  end,
  timer:sleep(rand:uniform(1000)),
  generate().
