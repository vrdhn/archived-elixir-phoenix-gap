defmodule GapWeb.Plug.SesionCookieTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Plug.Test

  alias GapWeb.Plug.SesionCookie

  @cookie_key "session_cookie"

  @one_year_secs 60 * 60 * 24 * 365
  @fixed_now ~U[2023-01-01 00:00:00Z]

  describe "SesionCookie plug" do
    test "generates new cookie and session when no cookie is present" do
      conn =
        :get
        |> conn("/groups")
        |> init_test_session(%{})
        |> SesionCookie.call(current_time: @fixed_now, session_lifetime: @one_year_secs)

      # Cookie should be set in response
      %{value: signed_token} = conn.resp_cookies[@cookie_key]
      assert is_binary(signed_token)

      # Session should contain new token and metadata
      token = get_session(conn, :session_cookie)
      expires_at = get_session(conn, :session_cookie_expires_at)
      status = get_session(conn, :session_cookie_status)

      assert token != nil
      assert status == "new"
      assert expires_at == DateTime.add(@fixed_now, @one_year_secs, :second)
    end

    test "reuses existing cookie and marks session as existing" do
      # Step 1: simulate initial request
      conn1 =
        :get
        |> conn("/groups")
        |> init_test_session(%{})
        |> SesionCookie.call(current_time: @fixed_now, session_lifetime: @one_year_secs)

      %{value: signed_token} = conn1.resp_cookies[@cookie_key]
      original_token = get_session(conn1, :session_cookie)

      # Step 2: simulate second request with same signed cookie
      conn2 =
        :get
        |> conn("/groups")
        |> put_req_cookie(@cookie_key, signed_token)
        |> init_test_session(%{})
        |> SesionCookie.call(current_time: @fixed_now, session_lifetime: @one_year_secs)

      # Cookie should be refreshed (may or may not match original depending on signing impl)
      %{value: new_signed_token} = conn2.resp_cookies[@cookie_key]
      reused_token = get_session(conn2, :session_cookie)
      status = get_session(conn2, :session_cookie_status)
      expires_at = get_session(conn2, :session_cookie_expires_at)

      assert is_binary(new_signed_token)
      assert reused_token == original_token
      assert status == "existing"
      assert expires_at == DateTime.add(@fixed_now, @one_year_secs, :second)
    end
  end
end
