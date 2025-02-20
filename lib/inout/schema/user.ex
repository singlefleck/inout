defmodule Inout.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :employee_id, :string
    field :password_hash, :string
    field :expected_login_time, :time
    field :total_leaves, :integer

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:employee_id, :password_hash, :expected_login_time, :total_leaves])
    |> validate_required([:employee_id, :password_hash])
    |> unique_constraint(:employee_id)
  end
end
