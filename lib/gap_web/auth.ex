defmodule GapWeb.Auth do
  def on_mount(:need_user, params, session, socket) do
    {:cont, socket}
  end
end
