defmodule Mgr.OCV.Distributed do
  use Membrane.Filter

  def_input_pad :input, demand_unit: :buffers, caps: Membrane.Caps.Video.Raw
  def_output_pad :output, caps: Membrane.Caps.Video.Raw

  def_options detector: [
                spec: Process.dest()
              ]

  @impl true
  def handle_init(options) do
    {:ok, Map.from_struct(options)}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, ctx, state) do
    %{caps: caps} = ctx.pads.input

    {:ok, faces} =
      GenServer.call(state.detector, {:detect, {buffer.payload, caps.width, caps.height}})

    buffer = Bunch.Struct.put_in(buffer, [:metadata, :faces], faces)
    {{:ok, buffer: {:output, buffer}}, state}
  end
end
