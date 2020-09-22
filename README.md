# Mgr

To run:
```
mix run --no-halt run.exs <norm | dist> <count of streams>
```

for example

```
mix run --no-halt run.exs dist 2
```

Killing the script before the stream finishes and running it right away again may lead to errors due to remaining gstreamer processes. For details, see `run.exs`.

Command for measurements_bb:
```
sar -P ALL 5 20 >measurements_bb/proc_norm_4.txt & ; mix run --no-halt run.exs norm 4 | tee measurements_bb/times_norm_4.txt
```