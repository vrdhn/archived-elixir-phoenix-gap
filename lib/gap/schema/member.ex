defmodule Gap.Schema.Member do
  @moduledoc """
  The Member Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :name, :string
    field :role, :string
    field :user_id, :id
    field :group_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:name, :role, :user_id, :group_id])
    |> validate_required([:name, :role, :user_id, :group_id])
    |> unique_constraint([:user_id, :group_id])
  end
end
