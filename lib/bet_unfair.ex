defmodule BetUnfair do
  alias BetUnfair.Repo
  alias BetUnfair.Models

  @moduledoc """
  Final deliverable for the Programming Scalable Systems course at ESTIINF UPM.
  (I enjoy calling it Bet Fun Fair because gambling is only a problem is you
  stop before you win big)

  BetUnfair keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # USERS
  # =====

  def user_create(id, name) do
    # TODO: Check if the id is unique (IDK how)
    # First of all we have to check if the user already exists in the DB
    case Repo.get_user(id) do
      {:ok, %{id: _}} ->
        {:error, {:repeated_user, "This user already exists in the system"}}

      {:ok, %{}} ->
        Repo.add_user(%Models.User{
          id: id,
          name: name,
          balance: 0
        })
    end
  end

  def user_deposit(id, amount) do
    case amount < 0 do
      true ->
        {:error, {:non_pos_deposit, "The deposit amount is not positive"}}

      _ ->
        # Obtain the old user and its balance
        {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id)
        # Calculate the new balance
        balance = old_balance + amount
        # Generate a changeset with the new balance and edit the user in the DB
        case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
          {:ok, _} -> :ok
          {:error, error} -> error
        end
    end
  end

  def user_withdraw(id, amount) do
    case amount < 0 do
      true ->
        {:error, {:non_pos_deposit, "The deposit amount is not positive"}}

      _ ->
        # Obtain the old user and its balance
        {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id)
        # Calculate the new balance
        balance = old_balance - amount

        case balance < 0 do
          true ->
            {:error, {:no_money, "Not enough money in the user balance"}}

          _ ->
            # Generate a changeset with the new balance and edit the user in the DB
            case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
              {:ok, _} -> :ok
              {:error, error} -> error
            end
        end
    end
  end

  def user_get(id) do
    case Repo.get_user(id) do
      {:ok, %{id: _}} = res -> res
      {:ok, %{}} -> {:error, "User does not exists"}
    end
  end

  def user_bets(id) do
    id |> Repo.get_user_bets()
  end

  # MARKETS
  # =======

  def market_create(name, description) do
    {:ok, %Models.Market{id: id}} =
      Repo.add_market(%Models.Market{
        name: name,
        description: description,
        status: :active
      })

    {:ok, id}
  end

  def market_list() do
    Repo.get_all_users()
  end

  def market_list_active() do
    Repo.get_status_markets(:active)
  end

  def market_cancel(id) do
    # IDK maybe depends on the algorithm
    {:ok}
  end

  def market_freeze(id) do
    # IDK maybe depends on the algorithm
    {:ok}
  end

  def market_settle(id, result) do
    # IDK maybe depends on the algorithm
    {:ok}
  end

  def market_bets(id) do
    Repo.get_market_bets(id)
  end

  def market_pending_backs(id) do
    Repo.get_market_pending_bets(id, :back)
  end

  def market_pending_lays(id) do
    Repo.get_market_pending_bets(id, :lay)
  end

  def market_get(id) do
    case Repo.get_market(id) do
      {:ok, %{id: _}} = res -> res
      {:ok, %{}} -> {:error, "Market does not exist"}
    end
  end

  # BETS
  # ====
  def bet_back(user_id, market_id, stake, odds) do
    case Repo.add_bet(%Models.Bet{
           bet_type: :back,
           user: user_id,
           market: market_id,
           original_stake: stake,
           odds: odds,
           status: :active,
           remaining_stake: stake
         }) do
      {:ok, %Models.Bet{id: id}} -> {:ok, id}
      {:error, error} -> error
    end
  end

  def bet_lay(user_id, market_id, stake, odds) do
    case Repo.add_bet(%Models.Bet{
           bet_type: :lay,
           user: user_id,
           market: market_id,
           original_stake: stake,
           odds: odds,
           status: :active,
           remaining_stake: stake
         }) do
      {:ok, %Models.Bet{id: id}} -> {:ok, id}
      {:error, error} -> error
    end
  end

  def bet_cancel(bet_id) do
    {:ok}
  end

  def bet_get(bet_id) do
    case Repo.get_bet(bet_id) do
      {:ok, %{id: _}} = res -> res
      {:ok, %{}} -> {:error, "This bet does not exists"}
    end
  end
end
