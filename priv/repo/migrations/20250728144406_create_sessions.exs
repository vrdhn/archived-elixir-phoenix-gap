defmodule Gap.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :session_cookie, :string
      add :user_token, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sessions, [:session_cookie])
  end
end
