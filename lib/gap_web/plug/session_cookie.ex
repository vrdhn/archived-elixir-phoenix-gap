defmodule GapWeb.Plug.SesionCookie do
  @moduledoc """
  This is the only place where cookie can be set in the /groups live session.
  Updates the cookie for a 1-year expiration (or custom).
  We only do this at first connect, so this should be fine.
  The session_cookie_status is set to "new" for a first-time visitor.
  """

  import Plug.Conn

  @cookie_key "session_cookie"
  @default_lifetime 60 * 60 * 24 * 365

  @secret_key_base "NjcyOWJhOTctZTRhNS00NTE2LTkwOTktMmM1MmZkZGY3NmVhCjRmYTE5ODViLWM0MjMtNGM5Ni1h"
  @signing_salt "MTlmZTg2"
  @signing_key Plug.Crypto.KeyGenerator.generate(@secret_key_base, @signing_salt)

  # Publicly reusable
  def sign(token) when is_binary(token) do
    Plug.Crypto.MessageVerifier.sign(token, @signing_key)
  end

  def verify(signed_token) when is_binary(signed_token) do
    Plug.Crypto.MessageVerifier.verify(signed_token, @signing_key)
  rescue
    _ -> :error
  end

  def init(opts) do
    opts
    |> Keyword.put_new(:session_lifetime, @default_lifetime)
    |> Keyword.put_new(:current_time, DateTime.utc_now())
  end

  def call(conn, opts) do
    conn = Plug.Conn.fetch_cookies(conn)
    now = Keyword.fetch!(opts, :current_time)
    lifetime = Keyword.fetch!(opts, :session_lifetime)

    expires_at = DateTime.add(now, lifetime, :second)

    case get_req_cookie(conn, @cookie_key) do
      nil ->
        token = generate_token()
        signed_token = sign(token)

        conn
        |> put_resp_cookie(@cookie_key, signed_token, cookie_opts(lifetime))
        |> put_session(:session_cookie, token)
        |> put_session(:session_cookie_expires_at, expires_at)
        |> put_session(:session_cookie_status, :new)

      signed_token ->
        token =
          case verify(signed_token) do
            {:ok, verified} -> verified
            :error -> generate_token()
          end

        signed_token = sign(token)

        conn
        |> put_resp_cookie(@cookie_key, signed_token, cookie_opts(lifetime))
        |> put_session(:session_cookie, token)
        |> put_session(:session_cookie_expires_at, expires_at)
        |> put_session(:session_cookie_status, :old)
    end
  end

  defp get_req_cookie(%Plug.Conn{req_cookies: req_cookies}, key) when is_binary(key) do
    Map.get(req_cookies, key)
  end

  defp cookie_opts(max_age) do
    [
      max_age: max_age,
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

  def testing_cookie() do
    generate_token() |> sign()
  end
end
