defmodule GapWeb.Live.GroupListTest do
  use GapWeb.ConnCase
  import Phoenix.LiveViewTest

  test "displays the welcome message", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/groups")

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
    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 1
  end

  test "open the chat and manage page", %{conn: conn} do
    {:ok, view, html_initial} = live(conn, ~p"/groups")

    {:ok, document} = Floki.parse_document(html_initial)

    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 0

    # Click the button
    _group =
      view
      |> element("#new_group_button")
      |> render_click()

    _chat =
      view
      |> element("#chat-0")
      |> render_click()

    _manage =
      view
      |> element("#manage-0")
      |> render_click()
  end
end
