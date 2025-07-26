defmodule Gap.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :auth_token, :string
    field :email_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:auth_token, :name, :email_hash])
    |> validate_required([:auth_token, :name])
    |> unique_constraint(:auth_token)
    |> unique_constraint(:email_hash)
  end
end
