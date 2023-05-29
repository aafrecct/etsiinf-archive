defmodule BetUnfair.Repo.Migrations.AddBaseSchemas do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :balance, :integer
    end

    create table(:markets) do
      add :name, :string
      add :description, :string
      add :status, :string
      add :result, :boolean, default: false
    end

    create table(:bets) do
      add :bet_type, :string
      add :user, references(:users, type: :string, name: "user")
      add :market, references(:markets, name: "market")
      add :original_stake, :integer
      add :remaining_stake, :integer
      add :odds, :integer
      add :status, :string
      add :matched, references(:bets, name: "matched")
    end
  end
end
