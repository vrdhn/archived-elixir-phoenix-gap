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
    html_group =
      view
      |> element("#new_group_button")
      |> render_click()

    {:ok, document} = Floki.parse_document(html_group)
    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 1
  end

  test "open the chat page", %{conn: conn} do
    {:ok, view, html_initial} = live(conn, ~p"/groups")
    {:ok, document} = Floki.parse_document(html_initial)

    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 0

    # Click the button
    html_group =
      view
      |> element("#new_group_button")
      |> render_click()

    {:ok, document} = Floki.parse_document(html_group)

    ## know the url for later checki.
    url =
      Floki.find(document, "table#groups-list tbody tr")
      |> hd()
      |> elem(2)
      |> List.last()
      |> elem(2)
      |> hd()
      |> elem(1)
      |> Enum.into(%{})
      |> Map.get("href")

    view
    |> element("#chat-0")
    |> render_click()

    assert_redirect(view, url, 100)

    {:ok, chat_view, _html} = live(conn, url)

    assert render(chat_view) =~ "CHAT"
  end

  test "open the manage page", %{conn: conn} do
    {:ok, view, html_initial} = live(conn, ~p"/groups")
    {:ok, document} = Floki.parse_document(html_initial)

    assert Floki.find(document, "table#groups-list tbody tr") |> length() == 0

    # Click the button
    html_group =
      view
      |> element("#new_group_button")
      |> render_click()

    {:ok, document} = Floki.parse_document(html_group)

    ## know the url for later checki.
    url =
      Floki.find(document, "table#groups-list tbody tr")
      |> hd()
      |> elem(2)
      |> Enum.at(2)
      |> elem(2)
      |> hd()
      |> elem(1)
      |> Enum.into(%{})
      |> Map.get("href")

    view
    |> element("#manage-0")
    |> render_click()

    assert_redirect(view, url, 100)

    {:ok, manage_view, _html} = live(conn, url)

    assert render(manage_view) =~ "MANAGE"
  end
end
