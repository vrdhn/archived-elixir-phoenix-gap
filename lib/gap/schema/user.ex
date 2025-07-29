defmodule Gap.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :user_token, :string
    field :email_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_token, :name, :email_hash])
    |> validate_required([:user_token, :name])
    |> unique_constraint(:user_token)
    |> unique_constraint(:email_hash)
  end
end
