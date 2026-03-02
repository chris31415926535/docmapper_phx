defmodule DocmapperPhx.Doctors.Doctor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:cpso, :integer, autogenerate: false}

  schema "doctors" do
    # field :cpso, :integer
    field :name, :string
    field :specialty, :string
    field :gender, :string
    field :primary_location, :string
    field :languages_spoken, :string
    field :phone_number, :string
    field :lat, :float
    field :lon, :float
    field :famdoc, :boolean, default: false


    # don't care about this
    # timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(doctor, attrs) do
    doctor
    |> cast(attrs, [:cpso, :name, :specialty, :gender, :primary_location, :languages_spoken, :phone_number, :lat, :lon, :famdoc])
    |> validate_required([:cpso, :name, :specialty, :gender, :primary_location, :languages_spoken, :phone_number, :lat, :lon, :famdoc])
  end
end
