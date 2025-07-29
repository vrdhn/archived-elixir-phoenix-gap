defmodule Gap.Schema.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :session_cookie, :string
    field :user_token, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:session_cookie, :user_token])
    |> validate_required([:session_cookie, :user_token])
    |> unique_constraint(:session_cookie)
  end
end
