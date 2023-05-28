defmodule BetUnfair.Repo do
  use Ecto.Repo,
    otp_app: :bet_unfair,
    adapter: Ecto.Adapters.Postgres
end
