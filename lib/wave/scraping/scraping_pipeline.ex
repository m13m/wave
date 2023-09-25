defmodule Wave.Scraping.ScrapingPipeline do
  use Broadway
  require Logger

  alias Wave.Scraping.Scraper
  alias Wave.Scraping.ScrapingPipeline
  alias Wave.Scraping.PageProducer
  alias Wave.Scraping.Scraper

  def start_link(_args) do
    options = [
      name: __MODULE__,
      producer: [
        module: {PageProducer, []},
        transformer: {ScrapingPipeline, :transform, []}
      ],
      processors: [
        default: [max_demand: 1, concurrency: 2]
      ],
      batchers: [
        default: [batch_size: 1, concurrency: 2]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    IO.inspect(message, label: "message")

    if Scraper.online?(message.data) do
      Broadway.Message.put_batch_key(message, message.data)
    else
      Broadway.Message.failed(message, "offline")
    end
  end

  def handle_batch(_batcher, [message], _batch_info, _context) do
    Logger.info("Batch Processor received #{message.data}")
    Scraper.work()
    [message]
  end

  def transform(event, _options) do
    IO.inspect(event, label: "transform_event")

    %Broadway.Message{
      data: event,
      acknowledger: {__MODULE__, :pages, []}
    }
  end

  def ack(:pages, _successful, _failed) do
    :ok
  end
end
