defmodule BetUnfair.Repo.Migrations.AddBaseSchemas do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :bet_type, :string
      add :user, :string
      add :market, :integer
      add :original_stake, :integer
      add :remaining_stake, :integer
      add :odds, :integer
      add :status, :string
      add :matched, references("bets")
    end

    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :balance, :integer
      add :bets, references("bets")
    end

    create table(:markets) do
      add :name, :string
      add :description, :string
      add :status, :string
      add :result, :boolean, default: false
      add :bets, references("bets")
    end
  end
end
