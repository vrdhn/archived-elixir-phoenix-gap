defmodule GapWeb.Plug.SesionCookie do
  @moduledoc """
  This is the only place where cookie can be set in the /groups live session,
  Updates the cookie for 1 year expiration.
  We only do this at first connect, so this should be fine.
  the session_cookie_stus is set to new for the first time visitor.
  """

  import Plug.Conn

  @cookie_key "session_cookie"
  @one_year_secs 60 * 60 * 24 * 365

  # Hardcoded secret key base — replace with your own secure random string!
  @secret_key_base "NjcyOWJhOTctZTRhNS00NTE2LTkwOTktMmM1MmZkZGY3NmVhCjRmYTE5ODViLWM0MjMtNGM5Ni1h"

  @signing_salt "MTlmZTg2"
  @signing_key Plug.Crypto.KeyGenerator.generate(@secret_key_base, @signing_salt)

  def init(opts), do: opts

  def call(conn, _opts) do
    expires_at = DateTime.utc_now() |> DateTime.add(@one_year_secs, :second)

    case get_req_cookie(conn, @cookie_key) do
      nil ->
        token = generate_token()
        signed_token = Plug.Crypto.MessageVerifier.sign(token, @signing_key)

        conn
        |> put_resp_cookie(@cookie_key, signed_token, cookie_opts())
        |> put_session(:session_cookie, token)
        |> put_session(:session_cookie_expires_at, expires_at)
        |> put_session(:session_cookie_status, "new")

      signed_token ->
        token = verify_token(signed_token) || generate_token()
        signed_token = Plug.Crypto.MessageVerifier.sign(token, @signing_key)

        conn
        |> put_resp_cookie(@cookie_key, signed_token, cookie_opts())
        |> put_session(:session_cookie, token)
        |> put_session(:session_cookie_expires_at, expires_at)
        |> put_session(:session_cookie_status, "existing")
    end
  end

  defp get_req_cookie(%Plug.Conn{req_cookies: req_cookies}, key) when is_binary(key) do
    Map.get(req_cookies, key)
  end

  defp verify_token(token) do
    case Plug.Crypto.MessageVerifier.verify(token, @signing_key) do
      {:ok, verified_token} -> verified_token
      :error -> nil
    end
  end

  defp cookie_opts do
    [
      max_age: @one_year_secs,
      http_only: true,
      same_site: "Lax",
      secure: Mix.env() == :prod,
      path: "/groups"
    ]
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end
