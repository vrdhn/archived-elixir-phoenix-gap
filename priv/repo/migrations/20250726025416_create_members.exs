defmodule Gap.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :name, :string
      add :role, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:members, [:user_id, :group_id])
  end
end
