defmodule GapWeb.Live.GroupChatTest do
  use GapWeb.ConnCase
  import Phoenix.LiveViewTest

  test "direct hit of chat without slug", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/groups/chat")

    {:ok, _document} = Floki.parse_document(render(view))

    ## TODO: should be redirect to /groups.
  end

  test "displays the welcome message", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/groups/manage/hello123")

    {:ok, _document} = Floki.parse_document(render(view))

    ## TODO: should be redirect to /groups.
  end
end
