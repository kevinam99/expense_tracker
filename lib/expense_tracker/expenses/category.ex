defmodule ExpenseTracker.Expenses.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :monthly_budget])
    |> validate_number(:monthly_budget, greater_than: 0)
    |> validate_length(:name, min: 3)
    |> validate_length(:description, min: 5)
    |> validate_required([:name, :description, :monthly_budget])
  end
end
