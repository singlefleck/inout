defmodule Inout.Login do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logins" do
    field :login_time, :utc_datetime
    field :logout_time, :utc_datetime
    belongs_to :user, Inout.User, foreign_key: :employee_id, references: :employee_id, type: :string

    timestamps()
  end

  def changeset(login, attrs) do
    login
    |> cast(attrs, [:employee_id, :login_time, :logout_time])
    |> validate_required([:employee_id, :login_time])
  end
end
