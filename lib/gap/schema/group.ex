defmodule Gap.Schema.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :group_token, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :group_token])
    |> validate_required([:name, :group_token])
    |> unique_constraint(:group_token)
  end
end
