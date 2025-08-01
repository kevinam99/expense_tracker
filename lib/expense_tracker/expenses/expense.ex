defmodule ExpenseTracker.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :date, :date
    field :description, :string
    field :amount, :decimal
    field :optional_notes, :string

    belongs_to(:category, ExpenseTracker.Expenses.Category)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:description, :amount, :date, :optional_notes, :category_id])
    |> validate_length(:description, min: 3)
    |> validate_number(:amount, greater_than: 0)
    |> validate_required([:description, :amount, :date, :category_id])
  end
end
