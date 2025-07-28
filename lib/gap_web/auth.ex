defmodule GapWeb.Auth do
  def need_user(conn, opts) do
    conn
  end

  def on_mount(:need_user, params, session, socket) do
    {:cont, socket}
  end
end
