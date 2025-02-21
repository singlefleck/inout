defmodule Inout.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :description, :string

    # Association with Organization
    belongs_to :organization, Inout.Organization

    # Association with Users
    has_many :users, Inout.User

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description, :organization_id])
    |> validate_required([:name, :organization_id])
    |> assoc_constraint(:organization)
  end
end
