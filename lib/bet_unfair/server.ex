defmodule Betunfair.Server do
  use GenServer
  alias Betunfair.Repo
  alias Betunfair.Models

  @moduledoc """
  La Jenny (Gen-ey)
  This module implements the basic genserver structure behind the bet market.
  """

  @impl true
  def init(exchange_name) do
    Repo.put_exchange_name(exchange_name)
    {:ok, exchange_name}
  end

  # USERS
  # =====

  @impl true
  def handle_call({:user_create, id, name}, _from, exchange_name) do
    case Repo.get_user(id, exchange_name) do
      {:error, _} ->
        case Repo.add_user(%Models.User{
               uid: id,
               name: name,
               exchange: exchange_name
             }) do
          {:ok, %{uid: uid}} -> {:reply, {:ok, uid}, exchange_name}
          _ -> {:reply, {:error, {:error_insert, "Something went wrong"}}, exchange_name}
        end

      {:ok, _} ->
        {:reply, {:error, {:error_user_exists, "User already exists"}}, exchange_name}
    end
  end

  @impl true
  def handle_call({:user_deposit, id, amount}, _from, exchange_name) do
    {:reply, inner_user_deposit(id, amount, exchange_name), exchange_name}
  end

  @impl true
  def handle_call({:user_withdraw, id, amount}, _from, exchange_name) do
    {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id, exchange_name)

    case {amount > 0, amount <= old_balance} do
      {false, _} ->
        {:reply, {:error, {:non_pos_deposit, "The withdraw amount is not positive"}}, exchange_name}

      {true, false} ->
        {:reply, {:error, {:no_money, "The withdraw amount exceeds balance"}}, exchange_name}

      {true, true} ->
        balance = old_balance - amount
        # Generate a changeset with the new balance and edit the user in the DB
        case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
          {:ok, _} -> {:reply, :ok, exchange_name}
          error -> {:reply, error, exchange_name}
        end
    end
  end

  @impl true
  def handle_call({:user_get, id}, _from, exchange_name) do
    case Repo.get_user(id, exchange_name) do
      {:ok, %{id: _}} = res -> {:reply, res, exchange_name}
      error -> {:reply, error, exchange_name}
    end
  end

  @impl true
  def handle_call({:user_bets, id}, _from, exchange_name) do
    case Repo.get_user(id, exchange_name) do
      {:error, _} = res ->
        res

      {:ok, user} ->
        user.id
        {:reply, Repo.get_user_bets(user.id), exchange_name}
    end
  end

  # MARKETS
  # =======

  @impl true
  def handle_call({:market_create, name, description}, _from, exchange_name) do
    {:ok, %Models.Market{id: id}} =
      Repo.add_market(%Models.Market{
        name: name,
        description: description,
        status: :active,
        exchange: exchange_name
      })

    {:reply, {:ok, id}, exchange_name}
  end

  @impl true
  def handle_call({:market_list}, _from, exchange_name) do
    {:reply, Repo.get_all_markets(exchange_name), exchange_name}
  end

  @impl true
  def handle_call({:market_freeze, id}, _from, exchange_name) do
    {:ok, market} = Repo.get_market(id)

    case Repo.edit_market(Ecto.Changeset.cast(market, %{status: :frozen}, [:status])) do
      {:ok, _} ->
        {:ok, market_bets} = Repo.get_market_bets(id, exchange_name)

        case Enum.reduce(market_bets, {true, 0}, &freeze_market_bet/2) do
          {true, count} ->
            {:reply, {:ok, "#{count} bets in market frozen."}, exchange_name}

          {false, count} ->
            {:reply, {:error, "#{count} bets frozen, but some couldn't be modified."}, exchange_name}
        end

      {:error, _} = res ->
        {:reply, res, exchange_name}
    end
  end

  @impl true
  def handle_call({:market_cancel, id}, _from, exchange_name) do
    {:ok, market} = Repo.get_market(id)

    case Repo.edit_market(Ecto.Changeset.cast(market, %{status: :cancelled}, [:status])) do
      {:ok, _} ->
        {:ok, bets} = Repo.get_market_bets(id, exchange_name)

        case Enum.reduce(bets, {true, 0}, &cancel_market_bet/2) do
          {true, count} ->
            {:reply, {:ok, "#{count} bets in market cancelled."}, exchange_name}

          {false, count} ->
            {:reply, {:error, "#{count} bets cancelled, but some couldn't be modified."}, exchange_name}
        end

      {:error, _} = res ->
        {:reply, res, exchange_name}
    end
  end

  @impl true
  def handle_call({:market_settle, id, result}, _from, exchange_name) do
    {:ok, market} = Repo.get_market(id)

    case Repo.edit_market(
           Ecto.Changeset.cast(
             market,
             %{result: result, status: :settled},
             [
               :result,
               :status
             ]
           )
         ) do
      {:ok, _} ->
        {:ok, market_bets} = Repo.get_market_bets(id, exchange_name)

        case Enum.reduce(
               market_bets,
               {true, 0, result},
               &settle_market_bet/2
             ) do
          {true, count, _} ->
            {:reply, {:ok, "#{count} bets in market settled."}, exchange_name}

          {false, count, _} ->
            {:reply, {:error, "#{count} bets settled, but some couldn't be modified."}, exchange_name}
        end

      {:error, _} = res ->
        {:reply, res, exchange_name}
    end
  end

  @impl true
  def handle_call({:market_list_active}, _from, exchange_name) do
    {:reply, Repo.get_status_markets(:active, exchange_name), exchange_name}
  end

  @impl true
  def handle_call({:market_bets, id}, _from, exchange_name) do
    {:reply, Repo.get_market_bets(id, exchange_name), exchange_name}
  end

  @impl true
  def handle_call({:market_pending_backs, id}, _from, exchange_name) do
    {:ok, bets} = Repo.get_market_pending_bets(id, :back, :asc, exchange_name)

    {:reply,
     {:ok,
      Enum.map(bets, fn x ->
        {x.odds, x.id}
      end)}, exchange_name}
  end

  @impl true
  def handle_call({:market_pending_lays, id}, _from, exchange_name) do
    {:ok, bets} = Repo.get_market_pending_bets(id, :lay, :desc, exchange_name)

    {:reply,
     {:ok,
      Enum.map(bets, fn x ->
        {x.odds, x.id}
      end)}, exchange_name}
  end

  @impl true
  def handle_call({:market_get, id}, _from, exchange_name) do
    case Repo.get_market(id) do
      {:ok, %{id: _}} = res -> {:reply, res, exchange_name}
      {:error, _} = error -> {:reply, error, exchange_name}
    end
  end

  @impl true
  def handle_call({:market_match, market_id}, _from, exchange_name) do
    {:ok, lays} = Repo.get_market_pending_bets(market_id, :lay, :desc, exchange_name)
    {:ok, backs} = Repo.get_market_pending_bets(market_id, :back, :asc, exchange_name)

    case match_bets(lays, backs) do
      {:ok} ->
        {:reply, :ok, exchange_name}
    end
  end

  # BETS
  # ====

  @impl true
  def handle_call({:bet_back, user_id, market_id, stake, odds}, _from, exchange_name) do
    place_bet(:back, user_id, market_id, stake, odds, exchange_name)
  end

  @impl true
  def handle_call({:bet_lay, user_id, market_id, stake, odds}, _from, exchange_name) do
    place_bet(:lay, user_id, market_id, stake, odds, exchange_name)
  end

  @impl true
  def handle_call({:bet_cancel, bet_id}, _from, exchange_name) do
    {:ok, bet} = Repo.get_bet(bet_id)
    %Models.User{uid: uid} = Repo.get(Models.User, bet.user)

    case bet.remaining_stake <= 0 do
      true ->
        case inner_user_deposit(uid, bet.remaining_stake, exchange_name) do
          {:ok, _} ->
            {:reply,
             Repo.edit_bet(
               Ecto.Changeset.cast(bet, %{remaining_stake: 0, status: :cancelled}, [
                 :remaining_stake,
                 :status
               ])
             ), exchange_name}

          error ->
            {:reply, error, exchange_name}
        end

      false ->
        {:reply, :ok, exchange_name}
    end
  end

  @impl true
  def handle_call({:bet_get, bet_id}, _from, exchange_name) do
    case Repo.get_bet(bet_id) do
      {:ok, %{id: _}} = res -> {:reply, res, exchange_name}
      {:error, _} = error -> {:reply, error, exchange_name}
    end
  end

  # PRIVATE FUNCTIONS
  # =================

  defp inner_user_deposit(id, amount, exchange) do
    case amount <= 0 do
      true ->
        {:error, {:non_pos_deposit, "The deposit amount is not positive"}}

      false ->
        # Obtain the old user and its balance
        {:ok, %Models.User{balance: old_balance} = user} = Repo.get_user(id, exchange)
        # Calculate the new balance
        balance = old_balance + amount
        # Generate a changeset with the new balance and edit the user in the DB
        case Ecto.Changeset.change(user, balance: balance) |> Repo.edit_user() do
          {:ok, _} = res -> res
          error -> error
        end
    end
  end

  defp cancel_market_bet(bet, {success, count}) do
    {:ok, market} =
      bet.market
      |> Repo.get_market()

    %Models.User{uid: uid} = Repo.get(Models.User, bet.user)

    case inner_user_deposit(uid, bet.original_stake, market.exchange) do
      {:ok, _} ->
        case Repo.edit_bet(Ecto.Changeset.cast(bet, %{status: :market_cancelled}, [:status])) do
          {:ok, _} -> {success, count + 1}
          {:error, _} -> {false, count}
        end

      {:error, _} ->
        {false, count}
    end
  end

  defp freeze_market_bet(bet, {success, count}) do
    {:ok, market} =
      bet.market
      |> Repo.get_market()

    %Models.User{uid: uid} = Repo.get(Models.User, bet.user)

    case bet.remaining_stake > 0 do
      true ->
        case inner_user_deposit(uid, bet.remaining_stake, market.exchange) do
          {:ok, _} ->
            case Repo.edit_bet(
                   Ecto.Changeset.cast(bet, %{remaining_stake: 0}, [:remaining_stake])
                 ) do
              {:ok, _} -> {success, count + 1}
              {:error, _} -> {false, count}
            end

          {:error, _} ->
            {false, count}
        end

      false ->
        {success, count + 1}
    end
  end

  defp settle_market_bet(bet, {success, count, result}) do
    {:ok, market} = Repo.get_market(bet.market)

    %Models.User{uid: uid} = Repo.get(Models.User, bet.user)

    acc =
      cond do
        {bet.bet_type, result} == {:lay, false} or {bet.bet_type, result} == {:back, true} ->
          earnings = (bet.original_stake - bet.remaining_stake) * bet.odds + bet.remaining_stake

          case inner_user_deposit(uid, earnings, market.exchange) do
            {:ok, _} ->
              {success, count + 1, result}

            {:error, _} ->
              {false, count, result}
          end

        true ->
          case bet.remaining_stake > 0 do
            true ->
              case inner_user_deposit(uid, bet.remaining_stake, market.exchange) do
                {:ok, _} ->
                  {success, count + 1, result}

                {:error, _} ->
                  {false, count, result}
              end

            false ->
              {success, count + 1, result}
          end
      end

    Ecto.Changeset.cast(bet, %{status: :market_settled}, [:status])
    acc
  end

  defp place_bet(kind, user_id, market_id, stake, odds, exchange_name) do

    case Repo.get_user(user_id, exchange_name) do
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
            # Please don't do this at home
            handle_call({:user_withdraw, user_id, stake}, __MODULE__, exchange_name)

            {:reply, {:ok, id}, exchange_name}

          {:error, error} ->
            {:reply, error, exchange_name}
        end

      error ->
        error
    end
  end

  defp max_matched_ammount(bet) do
    trunc(bet.remaining_stake * (bet.odds / 100 - 1))
  end
  
  defp match_bets([], _) do
    {:ok}
  end

  defp match_bets(_, []) do
    {:ok}
  end

  defp match_bets([hlay | lays], [hback | backs]) do

    IO.puts "Match bets called\n====================="
    IO.inspect hlay
    IO.inspect hback
    
    case hback.odds <= hlay.odds do
      false ->
        {:ok}

      true ->
        case max_matched_ammount(hback) >= hlay.remaining_stake do
          true ->
            IO.puts "Consuming lay stake"
            Repo.edit_bet(Models.Bet.update_remaining_stake(hlay, 0))

            Repo.edit_bet(
              Models.Bet.update_remaining_stake(
                hback,
                hback.remaining_stake - trunc(hlay.remaining_stake / (hlay.odds / 100) - hlay.remaining_stake)
                )
            )

          false ->
            IO.puts "Consuming back stake"
            Repo.edit_bet(Models.Bet.update_remaining_stake(hback, 0))

            Repo.edit_bet(
              Models.Bet.update_remaining_stake(
                hlay,
                hlay.remaining_stake - trunc(hback.remaining_stake * (hlay.odds / 100) - hback.remaining_stake)
              )
            )
        end

        match_bets(lays, backs)
    end
  end
end
