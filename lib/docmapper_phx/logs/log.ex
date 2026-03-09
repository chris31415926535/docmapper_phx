defmodule DocmapperPhx.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :ip, :string
    field :path, :string
    field :lat, :float
    field :lon, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:ip, :path, :lat, :lon])
    |> validate_required([:ip, :path])
  end
end
