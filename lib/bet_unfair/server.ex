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
    if amount > 0 do
      {:reply, change_user_balance(id, amount, exchange_name), exchange_name}
    else
      {:reply, {:error, "Can only deposit positive ammounts"}, exchange_name}
    end
  end

  @impl true
  def handle_call({:user_withdraw, id, amount}, _from, exchange_name) do
    if amount > 0 do
      {:reply, change_user_balance(id, -amount, exchange_name), exchange_name}
    else
      {:reply, {:error, "Can only withdraw positive ammounts"}, exchange_name}
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
            {:reply, {:error, "#{count} bets frozen, but some couldn't be modified."},
             exchange_name}
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
            {:reply, {:error, "#{count} bets cancelled, but some couldn't be modified."},
             exchange_name}
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
        market_matched_bets = Repo.get_all_matched_bets(id)

        Enum.reduce(
          market_bets,
          {true, 0},
          &settle_market_bet/2
        )

        case Enum.reduce(
               market_matched_bets,
               {true, 0, result},
               &settle_market_matched_bet/2
             ) do
          {true, count, _} ->
            {:reply, {:ok, "#{count} bets in market settled."}, exchange_name}

          {false, count, _} ->
            {:reply, {:error, "#{count} bets settled, but some couldn't be modified."},
             exchange_name}
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
    case market_match(market_id, exchange_name) do
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

    case bet.remaining_stake> 0 do
      true ->
        case change_user_balance(bet.user, bet.remaining_stake) do
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

  defp change_user_balance(id, amount) do
    # Obtain the old user and its balance
    user = Repo.get(Models.User, id)
    # Generate a changeset with the new balance and edit the user in the DB
    case Models.User.change_balance(user, amount) |> Repo.edit_user() do
      {:ok, _} = res -> res
      error -> error
    end
  end

  defp change_user_balance(uid, amount, exchange) do
    # Obtain the old user and its balance
    {:ok, user} = Repo.get_user(uid, exchange)
    # Generate a changeset with the new balance and edit the user in the DB
    case Models.User.change_balance(user, amount) |> Repo.edit_user() do
      {:ok, _} = res -> res
      error -> error
    end
  end

  defp cancel_market_bet(bet, {success, count}) do
    {:ok, market} =
      bet.market
      |> Repo.get_market()

    case change_user_balance(bet.user, bet.original_stake) do
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

    case bet.remaining_stake > 0 do
      true ->
        case change_user_balance(bet.user, bet.remaining_stake) do
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

  defp settle_market_bet(bet, {success, count}) do
    {:ok, market} = Repo.get_market(bet.market)

    case bet.remaining_stake > 0 do
      true ->
        case change_user_balance(bet.user, bet.remaining_stake) do
          {:ok, _} ->
            case Repo.edit_bet(
                   Ecto.Changeset.cast(bet, %{remaining_stake: 0, status: :market_settled}, [
                     :remaining_stake,
                     :status
                   ])
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

  defp settle_market_matched_bet(bet, {success, count, result}) do
    {:ok, market} = Repo.get_market(bet.market)

    case result do
      true ->
        # GANAN BACKS
        earnings = bet.lay_stake + bet.back_stake

        case change_user_balance(bet.back_user, earnings) do
          {:ok, _} ->
            {success, count + 1, result}

          {:error, _} ->
            {false, count, result}
        end

      false ->
        # GANAN LAYS
        earnings = bet.lay_stake + bet.back_stake

        case change_user_balance(bet.lay_user, earnings) do
          {:ok, _} ->
            {success, count + 1, result}

          {:error, _} ->
            {false, count, result}
        end
      end
  end

  defp place_bet(kind, user_id, market_id, stake, odds, exchange_name) do
    %{status: market_status} = Repo.get(Models.Market, market_id)
    case market_status do
      :active ->
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
                change_user_balance(user_id, -stake, exchange_name)
                {:reply, {:ok, id}, exchange_name}

              {:error, error} ->
                {:reply, error, exchange_name}
            end

          error ->
            {:reply, error, exchange_name}
        end

      _ -> {:reply, {:error, "Market not active"}, exchange_name}
    end
  end

  defp max_matched_ammount(bet) do
    trunc(bet.remaining_stake * (bet.odds - 100) / 100)
  end

  defp match_bets(top_back, top_lay) do
    case top_back.odds <= top_lay.odds do
      false ->
        :end

      true ->
        case max_matched_ammount(top_back) >= top_lay.remaining_stake do
          true ->
            Repo.edit_bet(Models.Bet.update_remaining_stake(top_lay, 0))

            odds = (top_back.odds - 100) / 100
            matched_stake = trunc(top_lay.remaining_stake / odds)

            new_top_back =
              Models.Bet.update_remaining_stake(
                top_back,
                top_back.remaining_stake - matched_stake
              )

            Repo.edit_bet(new_top_back)

            Repo.match_bets_create(%Models.MatchedBet{
              lay_user: top_lay.user,
              back_user: top_back.user,
              market: top_back.market,
              lay_stake: top_lay.remaining_stake,
              back_stake: matched_stake,
              odds: top_back.odds
            })

          false ->
            Repo.edit_bet(Models.Bet.update_remaining_stake(top_back, 0))

            odds = (top_lay.odds - 100) / 100
            matched_stake = trunc(top_back.remaining_stake * odds)

            new_top_lay =
              Models.Bet.update_remaining_stake(
                top_lay,
                top_lay.remaining_stake - matched_stake
              )

            Repo.edit_bet(new_top_lay)

            Repo.match_bets_create(%Models.MatchedBet{
              lay_user: top_lay.user,
              back_user: top_back.user,
              market: top_back.market,
              lay_stake: matched_stake,
              back_stake: top_back.remaining_stake,
              #! Puede que esto este mal
              odds: top_back.odds
            })
        end

        :continue
    end
  end

  defp market_match(market_id, exchange_name) do
    {:ok, backs} = Repo.get_market_pending_bets(market_id, :back, :asc, exchange_name)
    {:ok, lays} = Repo.get_market_pending_bets(market_id, :lay, :desc, exchange_name)

    case {backs, lays} do
      {[], _} ->
        {:ok}

      {_, []} ->
        {:ok}

      {[top_back | _], [top_lay | _]} ->
        case match_bets(top_back, top_lay) do
          :continue ->
            market_match(market_id, exchange_name)

          :end ->
            {:ok}
        end
    end
  end
end
