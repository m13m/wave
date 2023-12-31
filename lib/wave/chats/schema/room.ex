defmodule Wave.Chats.Schema.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wave.Chats.Schema.Message

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Phoenix.Param, key: :name}
  schema "rooms" do
    field :name, :string
    field :visibility, Ecto.Enum, values: [:public, :private], default: :public

    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :visibility])
    |> validate_required([:name, :visibility])
    |> validate_length(:name, min: 1, max: 80)
    |> unique_constraint(:name)
  end
end
