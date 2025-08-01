defmodule GapWeb.Live.GroupList do
  use GapWeb, :live_view

  alias Gap.Context.Accounts

  defp reget_memberships(socket) do
    memberships = Accounts.find_groups(socket.assigns[:current_user].id)
    ## add slug to each membership
    Enum.map(
      memberships,
      &Map.put(&1, :group_slug, Slug.slugify(&1.group.name))
    )
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :memberships, reget_memberships(socket))}
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
      <p>
        Hello
        <span class="bg-green-100 text-green-800 px-2 py-1 rounded">
          @{@current_user.name}
        </span>
        , Your groups ...
      </p>

      <table class="table-auto w-full" id="groups-list">
        <thead>
          <tr>
            <th class="px-4 py-2 text-left">Group</th>
            <th class="px-4 py-2 text-left">Role</th>
            <th class="px-4 py-2 text-left">Manage</th>
            <th class="px-4 py-2 text-left">Chats</th>
          </tr>
        </thead>
        <tbody>
          <%= for {m,idx} <- Enum.sort_by(@memberships, & &1.group_slug) |> Enum.with_index() do %>
            <tr>
              <td class="border px-4 py-2">{m.group.name}</td>
              <td class="border px-4 py-2">{m.member.role}</td>
              <td class="border px-4 py-2">
                <.link
                  navigate={~p"/groups/manage/#{m.group_slug}"}
                  class="text-blue-500"
                  id={"manage-#{idx}"}
                >
                  <.icon name="hero-cog-6-tooth" class="h-5 w-5 text-gray-500" />
                </.link>
              </td>
              <td class="border px-4 py-2">
                <.link
                  navigate={~p"/groups/chat/#{m.group_slug}"}
                  class="text-blue-500"
                  id={"chat-#{idx}"}
                >
                  <.icon name="hero-users" class="h-5 w-5 text-gray-500" />
                </.link>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    <div>
      <hr />
      <p></p>
      <hr />
      <.button
        id="new_group_button"
        phx-click="new_group"
        class="button bg-gradient-to-r from-purple-500 to-pink-500 text-white font-bold py-2 px-4 rounded shadow-lg hover:scale-105 transition-transform"
      >
        <.icon name="hero-check-circle" /> Create group
      </.button>
    </div>
    """
  end

  @impl true
  def handle_event("new_group", _params, socket) do
    # Probablymaking group and assigned user as adminshould move elsewhere.
    {:ok, group} = Accounts.create_group(Gap.Policy.FakeGroup.generate())

    Accounts.create_member(
      socket.assigns[:current_user],
      group,
      socket.assigns[:current_user].name,
      "owner"
    )

    {:noreply, assign(socket, :memberships, reget_memberships(socket))}
  end
end
