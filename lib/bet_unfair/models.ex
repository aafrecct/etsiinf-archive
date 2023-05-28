defmodule User do
  use Ecto.Schema
  @primary_key false

  schema "users" do
    field :uid,     :string, primary_key: true
    field :name,    :string
    field :balance, :integer
    has_many :bets, Bet
  end
end

defmodule Market do
  use Ecto.Schema

  schema "markets" do
    field :name,        :string
    field :description, :string
    field :status,      Ecto.Enum, values: [:active, :frozen, :cancelled, :settled]
    field :result,      :bool, default: false
    has_many :bets,     Bet
  end
end


defmodule Bet do
  use Ecto.Schema

  schema "bets" do
    field :bet_type,        Ecto.Enum, values: [:lay, :back]
    field :original_stake,  :integer
    field :remaining_stake, :integer
    field :odds,            :integer
    field :status           Ecto.Enum, values: [:active, :cancelled, :market_cancelled, :market_settled]
    has_many :matched,      Bet, foreign_key: :matched
    belongs_to :bmatched,   Bet, foreign_key: : :matched
    belongs_to :user,       User, foreign_key: :bets
    belongs_to :market,     Market, foreign_key: :bets
  end
end

