defmodule Gap.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :auth_token, :string
      add :name, :string
      add :email_hash, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:auth_token])
    create unique_index(:users, [:email_hash])
  end
end
