defmodule Betunfair.Repo do
  alias Betunfair.Models
  import Ecto.Query

  use Ecto.Repo,
    otp_app: :bet_unfair,
    adapter: Ecto.Adapters.Postgres

  # User operations
  # ===============
  def get_user(id, exchange) do
    case Models.User
         |> Betunfair.Repo.get_by(uid: id, exchange: exchange) do
      nil ->
        {:error, "No such user"}

      user ->
        {:ok, user}
    end
  end

  def add_user(user) do
    case user |> Betunfair.Repo.insert() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_add_user, "User cannot be inserted in the DB"}}
    end
  end

  def edit_user(user) do
    case user |> Betunfair.Repo.update() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_edit_user, "User cannot be edited in the DB"}}
    end
  end

  def get_all_users(exchange) do
    # Even if there are none it will return an empty map
    {:ok, Models.User |> Betunfair.Repo.all(exchange: exchange)}
  end

  def delete_user(user) do
    case user |> Betunfair.Repo.delete() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_delete_user, "User cannot be deleted"}}
    end
  end

  # Bet operations
  # ==============

  def get_user_bets(user_id) do
    # Returns all the bets from a given user_id
    {:ok,
     from(b in Models.Bet, where: b.user == ^user_id)
     |> Betunfair.Repo.all()}
  end

  def get_bet(id) do
    case Models.Bet |> Betunfair.Repo.get_by(id: id) do
      nil ->
        {:error, "No such bet"}

      bet ->
        {:ok, bet}
    end
  end

  def add_bet(bet) do
    case Betunfair.Repo.insert(bet) do
      {:ok, _} = res -> res
      _ -> {:error, {:error_add_bet, "Bet cannot be inserted in the DB"}}
    end
  end

  def edit_bet(bet) do
    case Betunfair.Repo.update(bet) do
      {:ok, _} = res ->
        res

      _ ->
        {:error, {:error_edit_bet, "Bet cannot be edited in the DB"}}
    end
  end

  def get_all_bets() do
    {:ok, Models.Bet |> Betunfair.Repo.all()}
  end

  def delete_bet(bet) do
    case Betunfair.Repo.delete(bet) do
      {:ok, _} = res -> res
      _ -> {:error, {:error_delete_bet, "Bet cannot be deleted"}}
    end
  end

  # Market operations
  # =================

  def get_market(id, exchange) do
    case Models.Market |> Betunfair.Repo.get_by(id: id, exchange: exchange) do
      nil -> {:error, "No such market"}
      market -> {:ok, market}
    end
  end

  def add_market(market) do
    case Betunfair.Repo.insert(market) do
      {:ok, _} = res -> res
      _ -> {:error, {:error_add_market, "Market cannot be inserted in DB"}}
    end
  end

  def edit_market(market) do
    case Betunfair.Repo.update(market) do
      {:ok, _} = res -> res
      _ -> {:error, {:error_edit_market, "Market cannot be edited in the DB"}}
    end
  end

  def get_all_markets(exchange) do
    {:ok, Models.Market |> Betunfair.Repo.all(exchange: exchange)}
  end

  def get_status_markets(status, exchange) do
    # Given a status returns all markets that match that status
    {:ok,
     Models.Market
     |> Betunfair.Repo.all(status: status, exchange: exchange)}
  end

  def get_market_bets(id, exchange) do
    # Given a market ID return all its bets
    {:ok,
     from(b in Models.Bet,
       join: m in Models.Market,
       on: b.market == ^id,
       where: m.exchange == ^exchange,
       order_by: b.odds
     )
     |> Betunfair.Repo.all()}
  end

  def get_market_pending_bets(id, type, order, exchange) do
    # Given market ID and bet type, get all pendings bets in the market that match the type
    {:ok,
     from(b in Models.Bet,
       join: m in Models.Market,
       on: b.market == m.id,
       where: m.id == ^id,
       where: m.exchange == ^exchange,
       where: b.bet_type == ^type,
       where: b.remaining_stake != 0,
       order_by: [{^order, b.odds}, {:asc, b.inserted_at}]
     )
     |> Betunfair.Repo.all()}
  end

  def delete_exchange(exchange) do
    from(
      b in Models.Bet,
      join: m in Models.Market,
      on: b.market == m.id,
      where: m.exchange == ^exchange
    )
    |> Betunfair.Repo.delete_all()

    from(
      m in Models.Market,
      where: m.exchange == ^exchange
    )
    |> Betunfair.Repo.delete_all()

    from(
      u in Models.User,
      where: u.exchange == ^exchange
    )
    |> Betunfair.Repo.delete_all()

    {:ok}
  end
end
