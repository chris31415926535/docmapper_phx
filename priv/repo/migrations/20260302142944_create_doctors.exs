defmodule DocmapperPhx.Repo.Migrations.CreateDoctors do
  use Ecto.Migration

  def change do
    create table(:doctors) do
      add :cpso, :integer
      add :name, :string
      add :specialty, :string
      add :gender, :string
      add :primary_location, :string
      add :languages_spoken, :string
      add :phone_number, :string
      add :lat, :float
      add :lon, :float
      add :famdoc, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
