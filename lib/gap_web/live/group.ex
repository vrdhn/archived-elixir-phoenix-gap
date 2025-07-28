defmodule GapWeb.Live.GroupLive do
  use GapWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p>Group Membership</p>
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
