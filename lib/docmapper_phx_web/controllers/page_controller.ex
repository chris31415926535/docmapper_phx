defmodule DocmapperPhxWeb.PageController do
  use DocmapperPhxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
