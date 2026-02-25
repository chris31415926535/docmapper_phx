defmodule DocmapperPhx do
  @moduledoc """
  DocmapperPhx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def test do
    5 |>
    Enum.any?(fn x -> x > 6 end)
  end
    
end
