defmodule Wave.Booking.Tickets do
  def tickets_available?(_event) do
    Process.sleep(Enum.random(100..200))
    true
  end

  def create_ticket(_user, _event) do
    Process.sleep(Enum.random(250..1000))
    true
  end

  def send_mail(_user) do
    Process.sleep(Enum.random(100..250))
  end

  @users [
    %{id: "1", email: "foo@example.com"},
    %{id: "2", email: "bar@example.com"},
    %{id: "3", email: "baz@example.com"}
  ]

  def users_by_ids(ids) when is_list(ids) do
    Enum.filter(@users, &(&1.id in ids))
  end

  def insert_all_tickets(messages) do
    # Repo.insert_all/3 if using `Ecto`

    messages
  end
end
