defmodule Betunfair.Models.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bets" do
    field :bet_type, Ecto.Enum, values: [:lay, :back]
    field :user, :integer
    field :market, :integer
    field :original_stake, :integer
    field :remaining_stake, :integer
    field :odds, :integer

    field :status, Ecto.Enum,
      values: [:active, :cancelled, :market_cancelled, :market_settled],
      default: :active

    timestamps()
    has_many :matched, Betunfair.Models.Bet, foreign_key: :bmatched
  end

  def update_remaining_stake(struct, remaining_stake) do
    struct
    |> cast(%{"remaining_stake" => remaining_stake}, [:remaining_stake])
  end
end

defmodule Betunfair.Models.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :uid, :string
    field :exchange, :string
    field :name, :string
    field :balance, :integer, default: 0
    has_many :bets, Betunfair.Models.Bet, foreign_key: :user
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :balance])
    |> unique_constraint(:unique_uid_in_exchange, name: :unique_uid_in_exchange)
  end
end

defmodule Betunfair.Models.Market do
  use Ecto.Schema

  schema "markets" do
    field :exchange, :string
    field :name, :string
    field :description, :string

    field :status, Ecto.Enum,
      values: [:active, :frozen, :cancelled, :settled],
      default: :active

    field :result, :boolean, default: false
    has_many :bets, Betunfair.Models.Bet, foreign_key: :market
  end
end
