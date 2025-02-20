defmodule Inout.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :employee_id, :string
    field :password_hash, :string
    field :expected_login_time, :time
    field :total_leaves, :integer

    belongs_to :team, Inout.Team  # Association to team

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:employee_id, :password_hash, :expected_login_time, :total_leaves, :team_id])  # Added :team_id
    |> validate_required([:employee_id, :password_hash, :team_id])  # Ensure team_id is required
    |> unique_constraint(:employee_id)
    |> foreign_key_constraint(:team_id)  # Enforce foreign key constraint
  end
end
