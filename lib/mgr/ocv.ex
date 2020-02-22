defmodule Mgr.OCV do
  use Membrane.Filter

  alias __MODULE__.Native

  def_input_pad :input, demand_unit: :buffers, caps: Membrane.Caps.Video.Raw
  def_output_pad :output, caps: Membrane.Caps.Video.Raw

  @impl true
  def handle_init(_) do
    {:ok, %{native: nil}}
  end

  @impl true
  def handle_stopped_to_prepared(_ctx, state) do
    {:ok, native} = Native.init()
    {:ok, %{state | native: native}}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, ctx, state) do
    %{caps: caps} = ctx.pads.input
    {:ok, faces} = Native.detect(buffer.payload, caps.width, caps.height, state.native)
    buffer = Bunch.Struct.put_in(buffer, [:metadata, :faces], faces)
    {{:ok, buffer: {:output, buffer}}, state}
  end
end
