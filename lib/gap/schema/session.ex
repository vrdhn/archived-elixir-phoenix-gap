defmodule Gap.Schema.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :session_cookie, :string
    field :auth_token, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:session_cookie, :auth_token])
    |> validate_required([:session_cookie, :auth_token])
    |> unique_constraint(:session_cookie)
  end
end
