defmodule Mgr.OCV do
  use Membrane.Sink

  alias __MODULE__.Native

  def_input_pad :input, demand_unit: :buffers, caps: Membrane.Caps.Video.Raw

  @impl true
  def handle_init(_) do
    {:ok, %{native: nil}}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {:ok, native} = Native.init()
    {{:ok, demand: :input}, %{state | native: native}}
  end

  @impl true
  def handle_write(:input, buffer, ctx, state) do
    %{caps: caps} = ctx.pads.input
    payload = Membrane.Payload.to_binary(buffer.payload)
    {:ok, faces} = Native.detect(payload, caps.width, caps.height, state.native)
    IO.inspect(faces)
    {{:ok, demand: :input}, state}
  end
end
