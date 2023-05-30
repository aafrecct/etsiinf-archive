defmodule BetUnfair do
  use GenServer
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
  
  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, %{name: name}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  defp matched_ammount(bet) do
    bet.remaining_stake * (bet.odds - 1)
  end

  defp update_bet(bet_changeset) do
    Repo.edit_bet(bet_changeset)
  end

  defp match_bets([hlay | lays], [hback | backs]) do
    case hback.odds <= hlay.odds do
      false ->
        {:ok}
      true ->
        case matched_ammount(hback) >= hlay.remaining_stake do
          false ->
            update_bet( Models.Bet.update_remaining_stake(hlay, 0) )
            update_bet( Models.Bet.update_remaining_stake(hback, hback.remaining_stake - hlay.remaining_stake) )
          true ->
            update_bet( Models.Bet.update_remaining_stake(hback, 0) )
            update_bet( Models.Bet.update_remaining_stake(hlay, hlay.remaining_stake - hback.remaining_stake) )
        end
        match_bets(lays, backs)
    end
  end
  
  @impl true
  def handle_call({:user_create, id, name}, _from, state) do
    case Repo.get_user(id, state.name) do
      {:error, _} -> 
        {:reply, 
        Repo.add_user(%Models.User{
          uid: id,
          name: name,
          exchange: state.name
        }), state}
      {:ok, _} ->
        {:reply, {:error, {:error_user_exists, "User already exists"}}, state}
    end
  end

  @impl true
  def handle_call({:user_deposit, id, amount}, _from, state) do
    case amount <= 0 do
      true ->
        {:reply, {:error, {:non_pos_deposit, "The deposit amount is not positive"}}, state}

      false ->
        # Obtain the old user and its balance
        {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id, state.name)
        # Calculate the new balance
        balance = old_balance + amount
        # Generate a changeset with the new balance and edit the user in the DB
        case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
          {:ok, _} -> {:reply, :ok, state}
          error -> {:reply, error, state}
        end
    end
  end

  @impl true
  def handle_call({:user_withdraw, id, amount}, _from, state) do
    {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id, state.name)
    case {amount > 0, amount <= old_balance} do
      {false, _} ->
        {:reply, {:error, {:non_pos_deposit, "The withdraw amount is not positive"}}, state}
      {true, false} ->
        {:reply, {:error, {:no_money, "The withdraw amount exceeds balance"}}, state}
      {true, true} ->
        balance = old_balance - amount
        # Generate a changeset with the new balance and edit the user in the DB
        case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
          {:ok, _} -> {:reply, :ok, state}
          error -> {:reply, error, state}
        end
    end
  end

  def handle_call({:user_get, id}, _from, state) do
    case Repo.get_user(id, state.name) do
      {:ok, %{id: _}} = res -> {:reply, res, state}
      error -> {:reply, error, state}
    end
  end
  
  def handle_call({:user_bets, id}, _from, state) do
    user = Repo.get_user(id, state.name)
    Repo.get_user_bets(user.id)
  end

  # USERS
  # =====

  def user_create(id, name) do
    GenServer.call(__MODULE__, {:user_create, id, name})
  end

  def user_deposit(id, amount) do
    GenServer.call(__MODULE__, {:user_deposit, id, amount})  
  end

  def user_withdraw(id, amount) do 
    GenServer.call(__MODULE__, {:user_withdraw, id, amount})  
  end

  def user_get(id) do
    GenServer.call(__MODULE__, {:user_get, id})
  end

  def user_bets(id) do
    GenServer.call(__MODULE__, {:user_bets, id})
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
