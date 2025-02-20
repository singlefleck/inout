defmodule Inout.Leave do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaves" do
    field :start_date, :date
    field :end_date, :date
    field :status, :string
    # New field for the reason of leave
    field :reason, :string

    belongs_to :user, Inout.User,
      foreign_key: :employee_id,
      references: :employee_id,
      type: :string

    timestamps()
  end

  def changeset(leave, attrs) do
    leave
    # Include reason
    |> cast(attrs, [:employee_id, :start_date, :end_date, :status, :reason])
    # Validate reason
    |> validate_required([:employee_id, :start_date, :end_date, :reason])
  end
end
