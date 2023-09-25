defmodule Wave.Booking.NotificationsPipeline do
  alias Wave.Booking.Tickets
  require Logger
  use Broadway

  @producer BroadwayRabbitMQ.Producer

  @producer_config [
    queue: "notifications_queue",
    declare: [durable: true],
    on_failure: :reject_and_requeue,
    qos: [prefetch_count: 100]
  ]

  def start_link(_args) do
    options = [
      name: __MODULE__,
      producer: [module: {@producer, @producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        email: [concurrency: 2, batch_size: 75, batch_timeout: 10_000],
        im: [concurrency: 2, batch_size: 75, batch_timeout: 10_0000]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def prepare_messages(messages, _context) do
    Enum.map(messages, fn message ->
      Broadway.Message.update_data(message, fn data ->
        [type, recipient] = String.split(data, ",")
        %{type: type, recipient: recipient}
      end)
    end)
  end

  def handle_message(_processor, %{data: %{type: "instant_message"}} = message, _context) do
    IO.inspect(message.data, pretty: true)

    message
    |> Broadway.Message.put_batcher(:im)

    # |> Broadway.Message.put_batch_key(message.data.recipient)
  end

  # triggered after every 10s with current config
  def handle_message(_processor, %{data: %{type: "email"}} = message, _context) do
    IO.inspect(message.data)

    message
    |> Broadway.Message.put_batcher(:email)

    # |> Broadway.Message.put_batch_key(message.data.type)
  end

  def handle_batch(:email, messages, batch_info, _context) do
    IO.inspect(batch_info, label: "#{inspect(self())} Batch")

    messages
  end

  def handle_batch(:im, messages, batch_info, _context) do
    IO.inspect(batch_info, label: "#{inspect(self())} Batch")

    messages
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    IO.inspect(batch_info, label: "#{inspect(self())} Batch")

    messages
  end
end
