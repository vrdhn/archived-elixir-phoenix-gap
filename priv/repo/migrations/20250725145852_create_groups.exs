defmodule Gap.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :group_token, :string
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:groups, [:group_token])
  end
end
