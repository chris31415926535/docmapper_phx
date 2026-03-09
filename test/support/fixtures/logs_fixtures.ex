defmodule DocmapperPhx.LogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DocmapperPhx.Logs` context.
  """

  @doc """
  Generate a log.
  """
  def log_fixture(attrs \\ %{}) do
    {:ok, log} =
      attrs
      |> Enum.into(%{
        ip: "some ip",
        lat: 120.5,
        lon: 120.5,
        path: "some path"
      })
      |> DocmapperPhx.Logs.create_log()

    log
  end
end
