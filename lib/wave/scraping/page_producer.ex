defmodule Wave.Scraping.PageProducer do
  alias Wave.Scraping.ScrapingPipeline
  use GenStage
  require Logger

  def init(initial_state) do
    IO.inspect(initial_state)
    Logger.info("PageProducer init")
    {:producer, initial_state, buffer_size: 3}
  end

  def handle_demand(demand, state) do
    Logger.info("PageProducer received demand for #{demand} pages")
    events = []
    {:noreply, events, state}
  end

  def scrape_pages(pages) when is_list(pages) do
    ScrapingPipeline
    |> Broadway.producer_names()
    |> List.first()
    |> GenStage.cast({:pages, pages})
  end

  def handle_cast({:pages, pages}, state) do
    # pages are the events that are list of webpages link that will be dispatched to our consumer
    {:noreply, pages, state}
  end
end
