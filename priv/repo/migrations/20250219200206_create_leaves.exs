defmodule Inout.Repo.Migrations.CreateLeaves do
  use Ecto.Migration

  def change do
    create table(:leaves) do
      add :employee_id, references(:users, column: :employee_id, type: :string), null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :status, :string, default: "pending"

      timestamps()
    end

    create index(:leaves, [:employee_id])
  end
end
