defmodule GapWeb.Router do
  use GapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GapWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GapWeb do
    pipe_through :browser

    get "/", PlatController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", GapWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gap, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GapWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", GapWeb do
    pipe_through [:browser, :need_user]

    live_session :need_user,
      on_mount: [{GapWeb.Auth, :need_user}] do
      live "/groups", Live.GroupLive
    end
  end

  pipeline :need_user do
    plug GapWeb.Plug.SesionCookie,
      current_time: DateTime.utc_now(),
      session_lifetime: 60 * 60 * 24 * 365
  end
end
