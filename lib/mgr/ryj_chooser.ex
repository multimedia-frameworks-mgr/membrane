defmodule Mgr.RyjChooser do
  use Membrane.Filter
  # TODO: check if caps match
  # TODO: make hysteresis an option and convert from time

  @hysteresis 30

  def_input_pad :input, availability: :on_request, demand_unit: :buffers, caps: :any
  def_output_pad :output, caps: :any

  @impl true
  def handle_init(_) do
    {:ok, %{frames: %{}, prev_id: nil, hysteresis: 0}}
  end

  @impl true
  def handle_demand(:output, _size, :buffers, _ctx, state) do
    demands =
      state.frames
      |> Bunch.KVEnum.filter_by_values(&(&1 == []))
      |> Enum.map(fn {id, _frames} -> {:demand, Pad.ref(:input, id)} end)

    {{:ok, demands}, state}
  end

  @impl true
  def handle_process(Pad.ref(:input, id), buffer, _ctx, state) do
    state |> put_in([:frames, id], [buffer]) |> maybe_send_buffer()
  end

  @impl true
  def handle_start_of_stream(Pad.ref(:input, id), _ctx, state) do
    state = put_in(state, [:frames, id], [])
    {{:ok, redemand: :output}, state}
  end

  @impl true
  def handle_end_of_stream(Pad.ref(:input, id), _ctx, state) do
    state |> Bunch.Access.delete_in([:frames, id]) |> maybe_send_buffer()
  end

  defp maybe_send_buffer(%{frames: frames} = state) when frames == %{} do
    {:ok, state}
  end

  defp maybe_send_buffer(%{frames: frames} = state) do
    cond do
      Bunch.KVEnum.any_value?(frames, &(&1 == [])) ->
        {:ok, state}

      state.hysteresis > 0 and Map.has_key?(frames, state.prev_id) ->
        [buffer] = frames[state.prev_id]

        state =
          %{state | frames: Bunch.Map.map_values(frames, fn _ -> [] end)}
          |> Map.update!(:hysteresis, &(&1 - 1))

        {{:ok, buffer: {:output, buffer}, redemand: :output}, state}

      true ->
        {id, [buffer]} =
          Enum.max_by(frames, fn {id, [buffer]} ->
            buffer.metadata.faces + if id == state.prev_id, do: 0.5, else: 0
          end)

        hysteresis = if id == state.prev_id, do: 0, else: @hysteresis

        state = %{
          state
          | hysteresis: hysteresis,
            prev_id: id,
            frames: Bunch.Map.map_values(frames, fn _ -> [] end)
        }

        {{:ok, buffer: {:output, buffer}, redemand: :output}, state}
    end
  end
end
