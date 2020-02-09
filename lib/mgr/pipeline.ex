defmodule Mgr.Pipeline do
  use Membrane.Pipeline

  def run() do
    {:ok, pid} = start_link(nil)
    :ok = play(pid)
    pid
  end

  @impl true
  def handle_init(_) do
    children = [
      file: %Membrane.Element.File.Source{location: "../ryj.h264"},
      parser: Membrane.Element.FFmpeg.H264.Parser,
      decoder: Membrane.Element.FFmpeg.H264.Decoder,
      ocv: Mgr.OCV
    ]

    links = [
      link(:file) |> to(:parser) |> to(:decoder) |> to(:ocv)
    ]

    {{:ok, %ParentSpec{children: children, links: links}}, %{}}
  end
end
