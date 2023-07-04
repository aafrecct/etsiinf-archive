defmodule Betunfair.Repo.Migrations.AddBaseSchemas do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uid, :string
      add :exchange, :string
      add :name, :string
      add :balance, :integer
    end

    create unique_index(:users, [:uid, :exchange], name: :unique_uid_in_exchange)

    create table(:markets) do
      add :exchange, :string
      add :name, :string
      add :description, :string
      add :status, :string
      add :result, :boolean, default: false
    end

    create table(:bets) do
      add :bet_type, :string
      add :user, references(:users, name: "user", on_delete: :delete_all)
      add :market, references(:markets, name: "market", on_delete: :delete_all)
      add :original_stake, :integer
      add :remaining_stake, :integer
      add :odds, :integer
      add :status, :string
      add :matched, references(:bets, name: "matched")
      add :inserted_at, :timestamp
      add :updated_at, :timestamp
    end
  end
end
