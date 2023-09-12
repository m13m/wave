defmodule WaveWeb.MessageComponent do
  use WaveWeb, :component

  def message_card(assigns) do
    ~H"""
    <div id="messages" phx-update="stream" class="flex flex-col gap-4 pb-14 pl-12 mt-24">
      <div :for={{id, message} <- @messages} id={id}>
        <div class="card bg-yellow-100 w-11/12">
          <%= raw(message.data) %>
          <%= present_date(message.inserted_at) %>
          <%= message.user.email %>
        </div>
      </div>
    </div>
    """
  end

  def relative_time(inserted_at) do
    {:ok, relative_str} =
      Timex.shift(inserted_at, minutes: -3) |> Timex.format("{relative}", :relative)

    relative_str
  end

  def present_date(date) do
    date
    |> Timex.format!("{D} {Mshort} {YYYY}")
  end
end
