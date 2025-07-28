defmodule GapWeb.Auth do
  use GapWeb, :live_view
  alias Gap.Context.Accounts

  def on_mount(
        :need_user,
        params,
        %{
          # always valid.
          "session_cookie" => cookie,
          "session_cookie_expires_at" => expires_at,
          # :new, :old
          "session_cookie_status" => status
        },
        socket
      ) do
    {user, msgcode} = figure_out_user(params["auth_token"], cookie, status)

    {message, error, update} =
      case msgcode do
        :oknew -> {"Welcome, first time user", nil, true}
        :okurl -> {"Succefully logged in", nil, true}
        :okcookie -> {"Welcome back", nil, false}
        :badurltoken -> {"Created new account", "Invalid or expired token", true}
        :badcookie -> {"Created new account", "Invalid or expired session", true}
      end

    if update do
      Accounts.update_session_token(cookie, user.auth_token)
    end

    {:cont,
     socket
     |> assign(:current_user, user)
     |> put_flash(:info, message)
     |> put_flash(:error, error)}
  end

  @doc "visible_or_Testing"
  def figure_out_user(url_auth_token, session_cookie, cookie_status) do
    cond do
      url_auth_token -> process_url_auto_token(url_auth_token)
      cookie_status == :old -> process_session_cookie(session_cookie)
      true -> {unwrap(Accounts.create_user()), :oknew}
    end
  end

  defp process_url_auto_token(url_auth_token) do
    case Accounts.find_user_by_token(url_auth_token) do
      nil -> {unwrap(Accounts.create_user()), :badurltoken}
      user -> {user, :okurl}
    end
  end

  def process_session_cookie(session_cookie) do
    case Accounts.find_token_from_session(session_cookie) do
      nil ->
        {unwrap(Accounts.create_user()), :badcookie}

      token ->
        case Accounts.find_user_by_token(token) do
          nil -> {unwrap(Accounts.create_user()), :badcookie}
          user -> {user, :okcookie}
        end
    end
  end

  defp unwrap({:ok, value}) do
    value
  end
end
