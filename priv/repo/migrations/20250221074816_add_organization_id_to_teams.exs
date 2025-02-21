defmodule Inout.Repo.Migrations.AddOrganizationIdToTeams do
  use Ecto.Migration

  def change do
    # Step 1: Add organization_id as a nullable column first
    alter table(:teams) do
      add :organization_id, references(:organizations, on_delete: :delete_all)
    end

    # Step 2: Insert a default organization if none exists
    execute """
    INSERT INTO organizations (id, name, inserted_at, updated_at)
    VALUES (1, 'Default Organization', NOW(), NOW())
    ON CONFLICT (id) DO NOTHING
    """

    # Step 3: Assign organization_id = 1 to all existing teams
    execute """
    UPDATE teams SET organization_id = 1 WHERE organization_id IS NULL
    """

    # Step 4: Apply NOT NULL constraint to organization_id
    execute "ALTER TABLE teams ALTER COLUMN organization_id SET NOT NULL"

    # Step 5: Add index for organization_id
    create index(:teams, [:organization_id])
  end
end
