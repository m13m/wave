defmodule Wave.GlobalSetup do
  alias Wave.Accounts
  alias Wave.Chats

  def run() do
    {:ok, user_1} =
      Accounts.register_user(%{
        email: "test2@test.com",
        password: "test2@test.com"
      })

    # create fake msg date

    {:ok, room} = Chats.create_room(%{name: "random"})

    Chats.create_message(%{
      data: "Hello World!",
      user_id: user_1.id,
      room_id: room.id
    })

    IO.puts("your room: #{room.id}")
  end
end

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wave.Repo.insert!(%Wave.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
