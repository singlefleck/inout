defmodule Inout.Leave do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaves" do
    field :start_date, :date
    field :end_date, :date
    field :status, :string
    belongs_to :user, Inout.User, foreign_key: :employee_id, references: :employee_id, type: :string

    timestamps()
  end

  def changeset(leave, attrs) do
    leave
    |> cast(attrs, [:employee_id, :start_date, :end_date, :status])
    |> validate_required([:employee_id, :start_date, :end_date])
  end
end
