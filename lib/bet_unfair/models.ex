defmodule BetUnfair.Models.Bet do
  use Ecto.Schema

  schema "bets" do
    field :bet_type, Ecto.Enum, values: [:lay, :back]
    field :user, :string
    field :market, :integer
    field :original_stake, :integer
    field :remaining_stake, :integer
    field :odds, :integer
    field :status, Ecto.Enum, values: [:active, :cancelled, :market_cancelled, :market_settled]
    has_many :matched, BetUnfair.Models.Bet, foreign_key: :bmatched
  end
end

defmodule BetUnfair.Models.User do
  use Ecto.Schema
  @primary_key {:id, :string, autogenerate: false}

  schema "users" do
    field :name, :string
    field :balance, :integer
    has_many :bets, BetUnfair.Models.Bet, foreign_key: :user
  end
end

defmodule BetUnfair.Models.Market do
  use Ecto.Schema

  schema "markets" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:active, :frozen, :cancelled, :settled]
    field :result, :boolean, default: false
    has_many :bets, BetUnfair.Models.Bet, foreign_key: :market
  end
end
