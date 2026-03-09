defmodule DocmapperPhx.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :ip, :string
      add :path, :string
      add :lat, :float
      add :lon, :float

      timestamps(type: :utc_datetime)
    end
  end
end
