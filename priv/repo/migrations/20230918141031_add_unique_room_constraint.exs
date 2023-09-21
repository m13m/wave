defmodule Wave.Repo.Migrations.AddUniqueRoomConstraint do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create unique_index("rooms", ["name"], concurrently: true)
  end
end
