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
      {:ok, %{}} ->
        Repo.add_user(%Models.User{
          id: id,
          name: name,
          balance: 0
        })

      {:ok, _} ->
        {:error, {:repeated_user, "This user already exists in the system"}}
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
      {:ok, %{}} -> {:error, "User does not exists"}
      {:ok, _} = res -> res
    end
  end

  def user_bets(id) do
    # Missing Bet Model.Repo implementation
    {:ok}
  end

  # MARKETS
  # =======

  def market_create(name, description) do
    {:ok}
  end

  def market_list() do
    {:ok}
  end

  def market_list_active() do
    {:ok}
  end

  def market_cancel(id) do
    {:ok}
  end

  def market_freeze(id) do
    {:ok}
  end

  def market_settle(id, result) do
    {:ok}
  end

  def market_create() do
    {:ok}
  end

  def market_bets(id) do
    {:ok}
  end

  def market_pending_backs(id) do
    {:ok}
  end

  def market_pending_lays(id) do
    {:ok}
  end

  def market_get(id) do
    {:ok}
  end

  # BETS
  # ====
  def bet_back(user_id, market_id, stake, odds) do
    {:ok}
  end

  def bet_lay(user_id, market_id, stake, odds) do
    {:ok}
  end

  def bet_cancel(bet_id) do
    {:ok}
  end

  def bet_get(bet_id) do
    {:ok}
  end
end
