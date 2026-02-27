# https://www.yellowduck.be/posts/adding-a-health-check-to-a-phoenix-web-app

defmodule DocmapperPhxWeb.Plug.HealthCheck do
  import Plug.Conn

  @behaviour Plug

  # init/1 is required by the Plug behaviour but can be left as-is.
  @impl true
  def init(opts), do: opts

  # If the request path matches "/health", we return a 200 response.
  @impl true
  def call(conn = %Plug.Conn{request_path: "/health"}, _opts) do
    conn
    |> send_resp(200, "")
    # Halts further processing of the request.
    |> halt()
  end

  # If the request path is anything else, we pass the connection along.
  def call(conn, _opts), do: conn
end
