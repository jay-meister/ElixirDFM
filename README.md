# DFM

#### Run:

```
iex -S mix
DFM.run()
DFM.run(from: ~U[2016-01-04 00:01:00Z], to: ~U[2016-01-04 13:00:00Z])
```

#### Test:

```bash
mix test
# watch tests:
bash watch.sh
```

#### QUESTIONS (which became assumptions):
- The final event in an trace has no recorded follower
- If a trace contains 1 event, we should it from discard from the matrix
- I have created a simple map where an event is only represented if it has at least one follower - thus not a true matrix representation:
```elixir
# For the following Traces:
#   event_1 -> event_2
#   event_1 -> event_2

# I have this shape:
%{
  event_1: %{event_1: 0, event_2: 2}
}

# instead of:
%{
  event_1: %{event_1: 0, event_2: 2}, 
  event_2: %{event_1: 0, event_2: 0}
}
```
___

#### NOTE: 
There is a key inefficiency that I am aware of:
- It is an eager solution & reads full file into memory before applying filters

Unfortunately I am not farmiliar with TypeSpecs but have done my best to incorporate them 
