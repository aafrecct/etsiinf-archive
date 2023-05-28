defmodule BetUnfair do
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
    {:ok}
  end
  
  def user_deposit(id, amount) do
    {:ok}
  end
  
  def user_withdraw(id, amount) do
    {:ok}
  end
  
  def user_get(id) do
    {:ok}
  end
  
  def user_get(id, amount) do
    {:ok}
  end

  def user_bets(id) do
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
