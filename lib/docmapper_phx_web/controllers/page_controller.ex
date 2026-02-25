defmodule DocmapperPhxWeb.PageController do
  use DocmapperPhxWeb, :controller

  def home(conn, params) do
    
    render(conn, :home)
  end
end
