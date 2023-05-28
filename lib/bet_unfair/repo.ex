defmodule BetUnfair.Repo do
  alias BetUnfair.Models

  use Ecto.Repo,
    otp_app: :bet_unfair,
    adapter: Ecto.Adapters.Postgres

  def get_user(id) do
    case Models.User
         |> BetUnfair.Repo.get_by(id: id) do
      nil ->
        {:ok, %{}}

      user ->
        {:ok, user}
    end
  end

  def add_user(user) do
    case user |> BetUnfair.Repo.insert() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_add_user, "User cannot be inserted in the DB"}}
    end
  end

  def edit_user(user) do
    case user |> BetUnfair.Repo.update() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_edit_user, "User cannot be edited in the DB"}}
    end
  end

  def get_all_users() do
    # Even if there are none it will return an empty map
    {:ok, Models.User |> BetUnfair.Repo.all()}
  end

  def delete_user(user) do
    case user |> BetUnfair.Repo.delete() do
      {:ok, _} = res -> res
      _ -> {:error, {:error_delete_user, "User cannot be deleted"}}
    end
  end
end
