defmodule Mgr.OCV.Distributed.Assigner do
  use GenServer

  def start_link(process_options \\ []) do
    GenServer.start_link(__MODULE__, nil, process_options)
  end

  def register(assigner, detector) do
    GenServer.call(assigner, {:register, detector})
  end

  def assign(assigner) do
    GenServer.call(assigner, :assign)
  end

  @impl true
  def init(_) do
    {:ok, Qex.new()}
  end

  @impl true
  def handle_call({:register, detector}, _from, detectors) do
    IO.inspect(:register)
    Process.monitor(detector)
    {:reply, :ok, Qex.push_front(detectors, detector)}
  end

  @impl true
  def handle_call(:assign, _from, detectors) do
    case Qex.pop(detectors) do
      {{:value, detector}, detectors} -> {:reply, {:ok, detector}, Qex.push(detectors, detector)}
      {:empty, detectors} -> {:reply, {:error, :no_detectors}, detectors}
    end
  end

  @impl true
  def handle_info({:DOWN, _monitor, :process, detector, _reason}, detectors) do
    detectors = detectors |> Enum.reject(&(&1 == detector)) |> Qex.new()
    {:noreply, detectors}
  end
end
