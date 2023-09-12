defmodule Wave.Chats.Schema.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wave.Accounts.User
  alias Wave.Chats.Schema.Room

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    field :data, :string
    belongs_to :user, User, type: :binary_id
    belongs_to :room, Room, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(message, attrs \\ %{}) do
    message
    |> cast(attrs, [:data, :user_id, :room_id])
    |> validate_required([:data, :user_id, :room_id])
  end
end
