defmodule Mgr.Pipeline do
  use Membrane.Pipeline

  def run() do
    {:ok, pid} = start_link(nil)
    :ok = play(pid)
    pid
  end

  @impl true
  def handle_init(_) do
    {children, links} =
      ["../ryj_270p.h264", "../ryj2_270p.h264"] |> Enum.map(&mk_input/1) |> Enum.unzip()

    children =
      [chooser: Mgr.RyjChooser, player: Membrane.Element.SDL.Player] ++ List.flatten(children)

    links = [link(:chooser) |> to(:player)] ++ links

    {{:ok, %ParentSpec{children: children, links: links}}, %{}}
  end

  defp mk_input(file) do
    ref = make_ref()

    children =
      [
        file: %Membrane.Element.File.Source{location: file},
        parser: %Membrane.Element.FFmpeg.H264.Parser{framerate: {25, 1}},
        decoder: Membrane.Element.FFmpeg.H264.Decoder,
        ocv: Mgr.OCV
      ]
      |> Bunch.KVEnum.map_keys(&{&1, ref})

    links = [
      link({:file, ref})
      |> to({:parser, ref})
      |> to({:decoder, ref})
      |> to({:ocv, ref})
      |> to(:chooser)
    ]

    {children, links}
  end
end
