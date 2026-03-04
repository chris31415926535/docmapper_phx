defmodule DocmapperPhx.Repo.Migrations.CreateDoctors do
  use Ecto.Migration

  def change do
    create table(:doctors, primary_key: false) do
      add :cpso, :integer, primary_key: true
      add :name, :string
      add :specialty, :string
      add :gender, :string
      add :primary_location, :string
      add :languages_spoken, :string
      add :phone_number, :string
      add :lat, :float
      add :lon, :float
      add :famdoc, :boolean, default: false, null: false
      add :lhin, :string

      # don't care about this
      # timestamps(type: :utc_datetime)
    end
  end
end
