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

alias Wave.Accounts
alias Wave.Chats

{:ok, user_1} =
  Accounts.register_user(%{
    email: "test@test.com",
    password: "test@test.com"
  })

# create fake msg date

{:ok, room} = Chats.create_room(%{name: "random"})

Chats.create_message(%{
  data: "Hello World!",
  user_id: user_1.id,
  room_id: room.id
})

IO.puts("your room: #{room.id}")
