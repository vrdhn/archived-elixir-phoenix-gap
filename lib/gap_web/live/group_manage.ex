defmodule GapWeb.Live.GroupManage do
  use GapWeb, :live_view

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, clear_flash(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if Phoenix.Flash.get(@flash, :info) do %>
        <div class="rounded bg-green-100 text-green-800 px-4 py-2 mb-2 border border-green-300">
          {Phoenix.Flash.get(@flash, :info)}
        </div>
      <% end %>

      <%= if Phoenix.Flash.get(@flash, :error) do %>
        <div class="rounded bg-red-100 text-red-800 px-4 py-2 mb-2 border border-red-300">
          {Phoenix.Flash.get(@flash, :error)}
        </div>
      <% end %>
    </div>
    <div>
      MANAGE
    </div>
    """
  end
end
