defmodule Mgr.Pipeline do
  use Membrane.Pipeline
  alias Mgr.OCV.Distributed.Assigner

  def run(opts \\ [mode: :norm]) do
    {:ok, pid} = start_link(opts)
    :ok = play(pid)
    pid
  end

  @impl true
  def handle_init(opts) do
    children = [
      udp: %Membrane.Element.UDP.Source{
        local_port_no: 5000,
        recv_buffer_size: 100_000
      },
      rtp: %Membrane.RTP.Session.ReceiveBin{fmt_mapping: %{96 => :H264}},
      chooser: Mgr.RyjChooser,
      player: Membrane.Element.SDL.Player
    ]

    links = [link(:udp) |> to(:rtp), link(:chooser) |> to(:player)]

    {{:ok, %ParentSpec{children: children, links: links}}, Map.new(opts)}
  end

  @impl true
  def handle_notification({:new_rtp_stream, ssrc, :H264}, :rtp, state) do
    IO.inspect("stream")
    ref = make_ref()

    ocv =
      case state.mode do
        :norm ->
          Mgr.OCV

        :dist ->
          {:ok, detector} = Assigner.assign(Assigner)
          %Mgr.OCV.Distributed{detector: detector}
      end

    children =
      [
        parser: %Membrane.Element.FFmpeg.H264.Parser{framerate: {25, 1}},
        decoder: Membrane.Element.FFmpeg.H264.Decoder,
        ocv: ocv
      ]
      |> Bunch.KVEnum.map_keys(&{&1, ref})

    links = [
      link(:rtp)
      |> via_out(Pad.ref(:output, ssrc))
      |> to({:parser, ref})
      |> to({:decoder, ref})
      |> to({:ocv, ref})
      |> to(:chooser)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, state}
  end

  @impl true
  def handle_notification({:new_rtp_stream, _ssrc, format}, :rtp, _state) do
    raise "Unsupported format #{inspect(format)}"
  end

  @impl true
  def handle_notification(_notification, _from, state) do
    {:ok, state}
  end
end
