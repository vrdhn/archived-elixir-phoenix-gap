defmodule GapWeb.Live.GroupLiveTest do
  use GapWeb.ConnCase
  import Phoenix.LiveViewTest

  test "displays the welcome message", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/groups")

    assert html =~ "Your groups"
  end
end
