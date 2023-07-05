defmodule Betunfair do
  alias Betunfair.Repo
  alias Betunfair.Models
  alias Betunfair.Server

  @moduledoc """
  Final deliverable for the Programming Scalable Systems course at ESTIINF UPM.
  (I enjoy calling it Bet Fun Fair because gambling is only a problem is you
  stop before you win big)

  Betunfair keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def start_link(exchange_name) when is_binary(exchange_name) do
    GenServer.start_link(Server, exchange_name, name: __MODULE__)
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
    GenServer.call(__MODULE__, {:market_create, name, description})
  end

  def market_match(market_id) do
    GenServer.call(__MODULE__, {:market_match, market_id})
  end

  def market_list() do
    GenServer.call(__MODULE__, {:market_list})
  end

  def market_cancel(id) do
    GenServer.call(__MODULE__, {:market_cancel, id})
  end

  def market_freeze(id) do
    GenServer.call(__MODULE__, {:market_freeze, id})
  end

  def market_settle(id, result) do
    GenServer.call(__MODULE__, {:market_settle, id, result})
  end

  def market_list_active() do
    GenServer.call(__MODULE__, {:market_list_active})
  end

  def market_bets(id) do
    GenServer.call(__MODULE__, {:market_bets, id})
  end

  def market_pending_backs(id) do
    GenServer.call(__MODULE__, {:market_pending_backs, id})
  end

  def market_pending_lays(id) do
    GenServer.call(__MODULE__, {:market_pending_lays, id})
  end

  def market_get(id) do
    GenServer.call(__MODULE__, {:market_get, id})
  end

  # BETS
  # ====

  def bet_back(user_id, market_id, stake, odds) do
    GenServer.call(__MODULE__, {:bet_back, user_id, market_id, stake, odds})
  end

  def bet_lay(user_id, market_id, stake, odds) do
    GenServer.call(__MODULE__, {:bet_lay, user_id, market_id, stake, odds})
  end

  def bet_cancel(bet_id) do
    GenServer.call(__MODULE__, {:bet_cancel, bet_id})
  end

  def bet_get(bet_id) do
    GenServer.call(__MODULE__, {:bet_get, bet_id})
  end
end
