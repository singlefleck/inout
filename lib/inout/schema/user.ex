defmodule Inout.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :employee_id, :string
    field :password_hash, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:employee_id, :password])
    |> validate_required([:employee_id, :password])
    |> unique_constraint(:employee_id)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
