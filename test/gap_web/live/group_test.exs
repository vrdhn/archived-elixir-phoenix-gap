defmodule GapWeb.Live.GroupLiveTest do
  use GapWeb.ConnCase
  import Phoenix.LiveViewTest

  test "displays the welcome message", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/groups")

    assert html =~ "Your groups"
  end

  test "add group", %{conn: conn} do
    {:ok, view, html_initial} = live(conn, ~p"/groups")

    {:ok, document} = Floki.parse_document(html_initial)

    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 0

    # Click the button
    html_grp1 =
      view
      |> element("#new_group_button")
      |> render_click()

    {:ok, document} = Floki.parse_document(html_grp1)
    IO.inspect(document)
    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 1
  end
end
