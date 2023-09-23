defmodule Wave.MessageProducer do
  use GenStage

  require Logger

  def start_link(init_state) do
    GenStage.start_link(__MODULE__, init_state)
  end

  def init(init_state) do
    Logger.info("MessageProducer init")
    {:producer, init_state}
  end

  def handle_demand(demand, state) do
    Logger.info("#{__MODULE__} producer received demand for #{demand} pages")
    events = []
    {:noreply, events, state}
  end
end
