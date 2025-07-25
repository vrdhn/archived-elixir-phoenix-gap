defmodule Gap.Repo do
  use Ecto.Repo,
    otp_app: :gap,
    adapter: Ecto.Adapters.Postgres
end
