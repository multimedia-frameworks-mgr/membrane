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