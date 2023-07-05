defmodule BetunfairCustomTest do
  use ExUnit.Case
  alias Betunfair.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "user_operations" do
    assert {:ok, _} = Betunfair.clean("testdb")
    assert {:ok, _} = Betunfair.start_link("testdb")
    assert {:ok, u1} = Betunfair.user_create("u1", "Usuario 1")
    assert {:ok, u2} = Betunfair.user_create("u2", "Usuario 2")
    assert {:ok, u3} = Betunfair.user_create("u3", "Usuario 3")
    assert is_error(Betunfair.user_create("u1", "Usuario 1"))
    assert is_error(Betunfair.user_create("u1", "Nombre incorrecto"))
    assert is_ok(Betunfair.user_deposit(u1, 2000))
    assert is_ok(Betunfair.user_deposit(u2, 2000))
    assert is_ok(Betunfair.user_deposit(u3, 2000))
    assert is_error(Betunfair.user_deposit(u1, -1))
    assert is_error(Betunfair.user_deposit(u1, 0))
    assert is_error(Betunfair.user_deposit("u11", 0))
    assert is_ok(Betunfair.user_withdraw(u1, 1000))
    assert is_ok(Betunfair.user_withdraw(u2, 2000))
    assert is_error(Betunfair.user_withdraw(u3, 3000))
    assert {:ok, %{balance: 1000}} = Betunfair.user_get(u1)
    assert {:ok, %{balance: 0}} = Betunfair.user_get(u2)
    assert {:ok, %{balance: 2000}} = Betunfair.user_get(u3)
  end

  test "bet_operations" do
    assert {:ok, _} = Betunfair.clean("testdb")
    assert {:ok, _} = Betunfair.start_link("testdb")
    assert {:ok, u1} = Betunfair.user_create("u1", "Usuario 1")
    assert is_ok(Betunfair.user_deposit(u1, 2000))
    assert {:ok, %{balance: 2000}} = Betunfair.user_get(u1)
    assert {:ok, m1} = Betunfair.market_create("apss", "Aprobamos PSS")
    assert {:ok, bb} = Betunfair.bet_back(u1, m1, 1000, 150)
    assert {:ok, %{id: ^bb, bet_type: :back, remaining_stake: 1000, odds: 150, status: :active}} =
             Betunfair.bet_get(bb)

    assert {:ok, bl} = Betunfair.bet_lay(u1, m1, 1000, 150)
    assert {:ok, %{id: ^bl, bet_type: :lay, remaining_stake: 1000, odds: 150, status: :active}} =
             Betunfair.bet_get(bl)

    assert {:ok, all_bets} = Betunfair.market_bets(m1)
    assert 2 = length(all_bets)
    assert {:ok, back_bets} = Betunfair.market_pending_backs(m1)
    assert 1 = length(back_bets)
    assert {:ok, lay_bets} = Betunfair.market_pending_lays(m1)
    assert 1 = length(lay_bets)
    assert {:ok, markets} = Betunfair.market_list()
    assert 1 = length(markets)
    assert {:ok, markets} = Betunfair.market_list_active()
    assert 1 = length(markets)
  end

  defp is_error(:error), do: true
  defp is_error({:error, _}), do: true
  defp is_error(_), do: false

  defp is_ok(:ok), do: true
  defp is_ok({:ok, _}), do: true
  defp is_ok(_), do: false
end
