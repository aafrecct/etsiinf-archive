defmodule Betunfair do
  use GenServer
  alias Betunfair.Repo
  alias Betunfair.Models

  @moduledoc """
  Final deliverable for the Programming Scalable Systems course at ESTIINF UPM.
  (I enjoy calling it Bet Fun Fair because gambling is only a problem is you
  stop before you win big)

  Betunfair keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, %{name: name}, name: __MODULE__)
  end

  def stop() do
    case GenServer.whereis(__MODULE__) do
      nil -> {:ok, "No active server"}
      _ -> GenServer.stop(__MODULE__)
    end
  end

  def clean(name) do
    Repo.delete_exchange(name)
    Betunfair.stop()
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

  @impl true
  def handle_cast({:match_bets, market_id}, state) do
    lays = Repo.get_market_bets_filter(market_id, state.name, :lay)
    backs = Repo.get_market_bets_filter(market_id, state.name, :back)

    case match_bets(lays, backs) do
      {:ok} ->
        {:noreply, state}
    end
  end

  defp match_bets([hlay | lays], [hback | backs]) do
    case hback.odds <= hlay.odds do
      false ->
        {:ok}

      true ->
        case matched_ammount(hback) >= hlay.remaining_stake do
          false ->
            update_bet(Models.Bet.update_remaining_stake(hlay, 0))

            update_bet(
              Models.Bet.update_remaining_stake(
                hback,
                hback.remaining_stake - hlay.remaining_stake
              )
            )

          true ->
            update_bet(Models.Bet.update_remaining_stake(hback, 0))

            update_bet(
              Models.Bet.update_remaining_stake(
                hlay,
                hlay.remaining_stake - hback.remaining_stake
              )
            )
        end

        match_bets(lays, backs)
    end
  end

  # USERS
  # =====

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

  def user_create(id, name) do
    GenServer.call(__MODULE__, {:user_create, id, name})
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

  def user_deposit(id, amount) do
    GenServer.call(__MODULE__, {:user_deposit, id, amount})
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

  def user_withdraw(id, amount) do
    GenServer.call(__MODULE__, {:user_withdraw, id, amount})
  end

  @impl true
  def handle_call({:user_get, id}, _from, state) do
    case Repo.get_user(id, state.name) do
      {:ok, %{id: _}} = res -> {:reply, res, state}
      error -> {:reply, error, state}
    end
  end

  def user_get(id) do
    GenServer.call(__MODULE__, {:user_get, id})
  end

  @impl true
  def handle_call({:user_bets, id}, _from, state) do
    case Repo.get_user(id, state.name) do
      {:error, _} = res ->
        res

      {:ok, user} ->
        user.id
        {:reply, Repo.get_user_bets(user.id), state}
    end
  end

  def user_bets(id) do
    GenServer.call(__MODULE__, {:user_bets, id})
  end

  # MARKETS
  # =======

  @impl true
  def handle_call({:market_create, name, description}, _from, state) do
    {:ok, %Models.Market{id: id}} =
      Repo.add_market(%Models.Market{
        name: name,
        description: description,
        status: :active,
        exchange: state.name
      })

    {:reply, id, state}
  end

  def market_create(name, description) do
    GenServer.call(__MODULE__, {:market_create, name, description})
  end

  @impl true
  def handle_call({:market_list}, _from, state) do
    {:reply, Repo.get_all_markets(state.name), state}
  end

  def market_list() do
    GenServer.call(__MODULE__, {:market_list})
  end

  defp cancel_market_bet(bet, {success, count}) do
    case GenServer.call(__MODULE__, {:user_deposit, bet.user, bet.original_stake}) do
      {:ok, _} ->
        case Repo.edit_bet(Ecto.Changeset.cast(bet, %{status: :market_cancelled}, [:status])) do
          {:ok, _} -> {success, count + 1}
          {:error, _} -> {false, count}
        end

      {:error, _} ->
        {false, count}
    end
  end

  @impl true
  def handle_call({:market_cancel, id}, _from, state) do
    case Repo.edit_market(
           Ecto.Changeset.cast(Repo.get_market(id, state.name), %{status: :cancelled}, [:status])
         ) do
      {:ok, _} ->
        case Enum.reduce(Repo.get_market_bets(id, state.name), {true, 0}, &cancel_market_bet/2) do
          {true, count} -> {:ok, "#{count} bets in market cancelled."}
          {false, count} -> {:error, "#{count} bets cancelled, but some couldn't be modified."}
        end

      {:error, _} = res ->
        res
    end
  end

  def market_cancel(id) do
    GenServer.call(__MODULE__, {:market_cancel, id})
  end

  defp freeze_market_bet(bet, {success, count}) do
    case GenServer.call(__MODULE__, {:user_deposit, bet.user, bet.remaining_stake}) do
      {:ok, _} ->
        case Repo.edit_bet(Ecto.Changeset.cast(bet, %{remaining_stake: 0}, [:remaining_stake])) do
          {:ok, _} -> {success, count + 1}
          {:error, _} -> {false, count}
        end

      {:error, _} ->
        {false, count}
    end
  end

  @impl true
  def handle_call({:market_freeze, id}, _from, state) do
    case Repo.edit_market(
           Ecto.Changeset.cast(Repo.get_market(id, state.name), %{status: :frozen}, [:status])
         ) do
      {:ok, _} ->
        case Enum.reduce(Repo.get_market_bets(id, state.name), {true, 0}, &freeze_market_bet/2) do
          {true, count} -> {:ok, "#{count} bets in market frozen."}
          {false, count} -> {:error, "#{count} bets frozen, but some couldn't be modified."}
        end

      {:error, _} = res ->
        res
    end
  end

  def market_freeze(id) do
    GenServer.call(__MODULE__, {:market_freeze, id})
  end

  defp settle_market_bet(bet, {success, count, result}) do
    acc =
      cond do
        {bet.bet_type, result} == {:lay, false} or {bet.bet_type, result} == {:back, true} ->
          earnings = (bet.original_stake - bet.remaining_stake) * bet.odds + bet.remaining_stake

          case GenServer.call(__MODULE__, {:user_deposit, bet.user, earnings}) do
            {:ok, _} ->
              {success, count + 1, result}

            {:error, _} ->
              {false, count, result}
          end

        true ->
          GenServer.call(__MODULE__, {:user_deposit, bet.user, bet.remaining_stake})
      end

    Ecto.Changeset.cast(bet, %{status: :market_settled}, [:status])
    acc
  end

  @impl true
  def handle_call({:market_settle, id, result}, _from, state) do
    case Repo.edit_market(
           Ecto.Changeset.cast(
             Repo.get_market(id, state.name),
             %{result: result, status: :settled},
             [
               :result,
               :status
             ]
           )
         ) do
      {:ok, _} ->
        case Enum.reduce(
               Repo.get_market_bets(id, state.name),
               {true, 0, result},
               &settle_market_bet/2
             ) do
          {true, count} -> {:ok, "#{count} bets in market settled."}
          {false, count} -> {:error, "#{count} bets settled, but some couldn't be modified."}
        end

      {:error, _} = res ->
        res
    end
  end

  def market_settle(id, result) do
    GenServer.call(__MODULE__, {:market_settle, id, result})
  end

  @impl true
  def handle_call({:market_list_active}, _from, state) do
    {:reply, Repo.get_status_markets(:active, state.name), state}
  end

  def market_list_active() do
    GenServer.call(__MODULE__, {:market_list_active})
  end

  @impl true
  def handle_call({:market_bets, id}, _from, state) do
    {:reply, Repo.get_market_bets(id, state.name), state}
  end

  def market_bets(id) do
    GenServer.call(__MODULE__, {:market_bets, id})
  end

  @impl true
  def handle_call({:market_pending_backs, id}, _from, state) do
    {:reply, Repo.get_market_pending_bets(id, :back, state.name), state}
  end

  def market_pending_backs(id) do
    GenServer.call(__MODULE__, {:market_pending_backs, id})
  end

  @impl true
  def handle_call({:market_pending_lays, id}, _from, state) do
    {:reply, Repo.get_market_pending_bets(id, :lay, state.name), state}
  end

  def market_pending_lays(id) do
    GenServer.call(__MODULE__, {:market_pending_lays, id})
  end

  @impl true
  def handle_call({:market_get, id}, _from, state) do
    case Repo.get_market(id, state.name) do
      {:ok, %{id: _}} = res -> {:reply, res, state}
      {:error, _} = error -> {:reply, error, state}
    end
  end

  defp place_bet(kind, user_id, market_id, stake, odds, state) do
    exchange = state.name

    case Repo.get_user(user_id, exchange) do
      {:ok, %{id: id}} ->
        case Repo.add_bet(%Models.Bet{
               bet_type: kind,
               user: id,
               market: market_id,
               original_stake: stake,
               odds: odds,
               status: :active,
               remaining_stake: stake
             }) do
          {:ok, %Models.Bet{id: id}} ->
            GenServer.call(__MODULE__, {:user_withdraw, user_id, stake})
            GenServer.cast(__MODULE__, {:match_bets, market_id})
            {:reply, {:ok, id}, state}

          {:error, error} ->
            {:reply, error, state}
        end

      error ->
        error
    end
  end

  def market_get(id) do
    GenServer.call(__MODULE__, {:market_get, id})
  end

  # BETS
  # ====

  @impl true
  def handle_call({:bet_back, user_id, market_id, stake, odds}, _from, state) do
    place_bet(:back, user_id, market_id, stake, odds, state)
  end

  def bet_back(user_id, market_id, stake, odds) do
    GenServer.call(__MODULE__, {:bet_back, user_id, market_id, stake, odds})
  end

  @impl true
  def handle_call({:bet_lay, user_id, market_id, stake, odds}, _from, state) do
    place_bet(:lay, user_id, market_id, stake, odds, state)
  end

  def bet_lay(user_id, market_id, stake, odds) do
    GenServer.call(__MODULE__, {:bet_lay, user_id, market_id, stake, odds})
  end

  @impl true
  def handle_call({:bet_cancel, bet_id}, _from, state) do
    bet = Repo.get_bet(bet_id)

    case GenServer.call(__MODULE__, {:user_deposit, bet.user, bet.remaining_stake}) do
      {:ok, _} ->
        {:reply,
         Repo.edit_bet(
           Ecto.Changeset.cast(bet, %{remaining_stake: 0, status: :cancelled}, [
             :remaining_stake,
             :status
           ])
         ), state}

      error ->
        {:reply, error, state}
    end
  end

  def bet_cancel(bet_id) do
    GenServer.call(__MODULE__, {:bet_cancel, bet_id})
  end

  @impl true
  def handle_call({:bet_get, bet_id}, _from, state) do
    case Repo.get_bet(bet_id) do
      {:ok, %{id: _}} = res -> {:reply, res, state}
      {:error, _} = error -> {:reply, error, state}
    end
  end

  def bet_get(bet_id) do
    GenServer.call(__MODULE__, {:bet_get, bet_id})
  end
end
