defmodule GapWeb.AuthTest do
  use Gap.DataCase, async: true

  alias GapWeb.Auth
  alias Gap.Context.Accounts

  describe "figure_out_user/3 with real database" do
    test "uses valid user_token from URL (msgcode: :okurl)" do
      {:ok, user} = Accounts.create_user()
      {result_user, code} = Auth.figure_out_user(user.user_token, "ignored", :new)

      assert result_user.id == user.id
      assert code == :okurl
    end

    test "falls back when user_token is invalid (msgcode: :badurltoken)" do
      {user, code} = Auth.figure_out_user("invalid_token", "cookie", :new)

      assert is_map(user)
      assert code == :badurltoken
    end

    test "uses valid session cookie (msgcode: :okcookie)" do
      {:ok, user} = Accounts.create_user()
      cookie = GapWeb.Plug.SesionCookie.testing_cookie()
      {:ok, _update_user} = Accounts.update_session_token(cookie, user.user_token)

      {result_user, code} = Auth.figure_out_user(nil, cookie, :old)

      assert result_user.id == user.id
      assert code == :okcookie
    end

    test "falls back when session cookie has no token (msgcode: :badcookie)" do
      {user, code} = Auth.figure_out_user(nil, "nonexistent_cookie", :old)

      assert is_map(user)
      assert code == :badcookie
    end

    test "session cookie returns token, but user lookup fails (msgcode: :badcookie)" do
      cookie = GapWeb.Plug.SesionCookie.testing_cookie()
      bad_token = "token_that_does_not_map_to_user"

      {:ok, _new_user} = Accounts.update_session_token(cookie, bad_token)

      {user, code} = Auth.figure_out_user(nil, cookie, :old)

      assert is_map(user)
      assert code == :badcookie
    end

    test "creates new user when no token and new cookie (msgcode: :oknew)" do
      {user, code} = Auth.figure_out_user(nil, "irrelevant", :new)

      assert is_map(user)
      assert code == :oknew
    end
  end
end
