defmodule ExpenseTracker.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :date, :date
    field :description, :string
    field :purpose, :string
    field :amount, :decimal
    field :optional_notes, :string

    belongs_to(:category, ExpenseTracker.Expenses.Category)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:purpose, :description, :amount, :date, :optional_notes])
    |> validate_length(:purpose, min: 3)
    |> validate_length(:description, min: 3)
    |> validate_number(:amount, greater_than: 0)
    |> validate_required([:purpose, :description, :amount, :date])
  end
end
