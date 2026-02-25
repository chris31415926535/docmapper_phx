defmodule DocmapperPhx.Repo do
  use Ecto.Repo,
    otp_app: :docmapper_phx,
    adapter: Ecto.Adapters.Postgres
end
