defmodule Inout.Repo.Migrations.AddReasonToLeaves do
  use Ecto.Migration

  def change do
    alter table(:leaves) do
      add :reason, :string
    end
  end
end
