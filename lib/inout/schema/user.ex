defmodule Inout.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :employee_id, :string
    field :password_hash, :string
    field :expected_login_time, :time
    field :total_leaves, :integer

    # Association to team
    belongs_to :team, Inout.Team

    timestamps()
  end

  def changeset(user, attrs) do
    user
    # Added :team_id
    |> cast(attrs, [:employee_id, :password_hash, :expected_login_time, :total_leaves, :team_id])
    # Ensure team_id is required
    |> validate_required([:employee_id, :password_hash, :team_id])
    |> unique_constraint(:employee_id)
    # Enforce foreign key constraint
    |> foreign_key_constraint(:team_id)
  end
end
