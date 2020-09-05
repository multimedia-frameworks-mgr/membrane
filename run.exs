alias Mgr.OCV.Distributed.Assigner

[mode, clients] = System.argv()
mode = String.to_atom(mode)
IO.inspect(mode)
{clients, ""} = Integer.parse(clients)

if mode == :dist do
  unless Node.alive?() do
    {:ok, _pid} = Node.start(:"master@MacBook-Pro-MatHek", :shortnames)
  end

  {:ok, _pid} = Assigner.start_link(name: Assigner)
end

Mgr.Pipeline.run(mode: mode)

Process.sleep(2000)

["../ryj_270p.h264", "../ryj2_270p.h264"]
|> Stream.cycle()
|> Enum.take(clients)
|> Enum.each(fn src ->
  if mode == :dist do
    Task.start_link(fn ->
      :os.cmd('mix run run_detector.exs')
    end)
  end

  Task.start_link(fn ->
    Process.sleep(10000)

    :os.cmd(
      'gst-launch-1.0 filesrc location=#{src} ! h264parse ! rtph264pay pt=96 ! udpsink host=127.0.0.1 port=5000'
    )
  end)
end)
