defmodule DocmapperPhxWeb.Router do
  use DocmapperPhxWeb, :router

  pipeline :browser do
    plug :check_headers
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DocmapperPhxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  def check_headers(conn, _opts) do
    # if Application.get_env(:docmapper_phx, :do_logging) == :prod do
      ip = get_ip(get_req_header(conn, "x-forwaded-for"))
      req_path = conn.request_path
      # IO.inspect(ip, label: "*** IP: ")
      # IO.inspect(req_path, label: "*** req_path: ")
      DocmapperPhx.Logs.create_log(%{ip: ip, path: req_path})
      |> IO.inspect()
    # end

    conn
  end

  def get_ip([ip]), do: ip
  def get_ip(_), do: "unknown"

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DocmapperPhxWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/map", MapLive
    live "/stats", StatsLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", DocmapperPhxWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:docmapper_phx, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DocmapperPhxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
