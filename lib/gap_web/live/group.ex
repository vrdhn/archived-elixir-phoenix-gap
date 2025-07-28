defmodule GapWeb.Live.GroupLive do
  use GapWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if Phoenix.Flash.get(@flash, :info) do %>
        <div class="rounded bg-green-100 text-green-800 px-4 py-2 mb-2 border border-green-300">
          {live_flash(@flash, :info)}
        </div>
      <% end %>

      <%= if live_flash(@flash, :error) do %>
        <div class="rounded bg-red-100 text-red-800 px-4 py-2 mb-2 border border-red-300">
          {live_flash(@flash, :error)}
        </div>
      <% end %>
      <p>
        Hello
        <span class="bg-green-100 text-green-800 px-2 py-1 rounded">
          @{@current_user.name}
        </span>
        , Your groups ...
      </p>
    </div>
    <div>
      <hr />
      <p></p>
      <hr />
      <.button>
        Create Group
      </.button>
    </div>
    """
  end
end
