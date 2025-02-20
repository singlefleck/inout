defmodule Inout.Repo.Migrations.AlterUsersTableAddTeam do
  use Ecto.Migration

  def change do
    # Step 1: Add team_id as a nullable column first
    alter table(:users) do
      add :team_id, references(:teams, on_delete: :delete_all)
    end

    # Step 2: Insert a default team with id = 1
    execute """
    INSERT INTO teams (id, name, inserted_at, updated_at)
    VALUES (1, 'Default Team', NOW(), NOW())
    ON CONFLICT (id) DO NOTHING
    """

    # Step 3: Assign team_id = 1 to all existing users
    execute """
    UPDATE users SET team_id = 1 WHERE team_id IS NULL
    """

    # Step 4: Apply NOT NULL constraint to team_id
    execute "ALTER TABLE users ALTER COLUMN team_id SET NOT NULL"

    # Step 5: Add index for team_id
    create index(:users, [:team_id])

    # Ensure employee_id remains unique

    # Fix expected_login_time and total_leaves defaults if needed
    execute "ALTER TABLE users ALTER COLUMN expected_login_time SET DEFAULT '09:00:00'"
    execute "ALTER TABLE users ALTER COLUMN total_leaves SET DEFAULT 20"
  end
end
