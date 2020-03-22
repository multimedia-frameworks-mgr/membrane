defmodule Mgr.OCV.Distributed.Detector do
  use GenServer
  alias Mgr.OCV.Native

  def start_link(process_options \\ []) do
    GenServer.start_link(__MODULE__, nil, process_options)
  end

  @impl true
  def init(_) do
    {:ok, native} = Native.init()
    {:ok, %{native: native}}
  end

  @impl true
  def handle_call({:detect, {payload, width, height}}, _from, state) do
    result = Native.detect(payload, width, height, state.native)
    {:reply, result, state}
  end
end
