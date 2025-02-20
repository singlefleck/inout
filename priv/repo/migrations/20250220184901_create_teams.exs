defmodule Inout.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end
  end
end
