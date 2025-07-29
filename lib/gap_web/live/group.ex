defmodule GapWeb.Live.GroupLive do
  use GapWeb, :live_view

  alias Gap.Context.Accounts

  def mount(_params, _session, socket) do
    memberships = Accounts.find_groups(socket.assigns[:current_user].id)
    {:ok, assign(socket, :memberships, memberships)}
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
      <ul>
        <%= for membership <- @memberships do %>
          <li>{membership.member.name}@{membership.group.name} .. {membership.member.role}</li>
        <% end %>
      </ul>
    </div>
    <div>
      <hr />
      <p></p>
      <hr />
      <.button
        phx-click="new_group"
        class="button bg-gradient-to-r from-purple-500 to-pink-500 text-white font-bold py-2 px-4 rounded shadow-lg hover:scale-105 transition-transform"
      >
        <.icon name="hero-check-circle" /> Create group
      </.button>
    </div>
    """
  end

  def handle_event("new_group", _params, socket) do
    # Probablymaking group and assigned user as adminshould move elsewhere.
    {:ok, group} = Accounts.create_group(Gap.Policy.FakeGroup.generate())

    Accounts.create_member(
      socket.assigns[:current_user],
      group,
      socket.assigns[:current_user].name,
      "owner"
    )

    memberships = Accounts.find_groups(socket.assigns[:current_user].id)
    {:noreply, assign(socket, :memberships, memberships)}
  end
end
