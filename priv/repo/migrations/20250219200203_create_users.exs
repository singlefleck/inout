defmodule Inout.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    drop table(:users)

    create table(:users) do
      add :employee_id, :string, null: false
      add :password_hash, :string, null: false
      # Corrected default
      add :expected_login_time, :time, default: "09:00:00"
      add :total_leaves, :integer, default: 20

      timestamps()
    end

    create unique_index(:users, [:employee_id])
  end
end
