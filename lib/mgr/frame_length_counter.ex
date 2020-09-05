defmodule Mgr.FrameLengthCounter do
  use Membrane.Filter

  def_input_pad :input, caps: :any, demand_unit: :buffers
  def_output_pad :output, caps: :any

  @impl true
  def handle_init(_opts) do
    {:ok, %{last_timestamp: nil}}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    {{:ok, demand: {:input, size}}, state}
  end

  @impl true
  def handle_process(:input, buffer, _ctx, state) do
    now = Membrane.Time.monotonic_time()

    if state.last_timestamp do
      IO.inspect(Membrane.Time.to_milliseconds(now - state.last_timestamp))
    end

    {{:ok, buffer: {:output, buffer}}, %{state | last_timestamp: now}}
  end
end
