defmodule Inout.Repo.Migrations.CreateLogins do
  use Ecto.Migration

  def change do
    create table(:logins) do
      add :employee_id, references(:users, column: :employee_id, type: :string), null: false
      add :login_time, :utc_datetime, null: false
      add :logout_time, :utc_datetime

      timestamps()
    end

    create index(:logins, [:employee_id])
  end
end
