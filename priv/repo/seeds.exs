# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExpenseTracker.Repo.insert!(%ExpenseTracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ExpenseTracker.Expenses.Category
alias ExpenseTracker.Repo
alias ExpenseTracker.Expenses.Expense

for category <- ["Food", "Transportation", "Entertainment"] do
  monthly_budget = Enum.random(100..1200) |> to_string() |> Decimal.new()
  amount = Enum.random(2..200) |> to_string() |> Decimal.new()

  random_expense_name =
    [?a..?z, ?A..?Z, ?0..?9] |> Enum.concat() |> Enum.take_random(4) |> List.to_string()

  category =
    %Category{
      description: "some description",
      monthly_budget: monthly_budget,
      name: category
    }
    |> Repo.insert!()

  expenses_count = Enum.random(1..10)

  for _ <- 1..expenses_count do
    %Expense{
      date: ~D[2025-07-29],
      optional_notes: "some optional_notes",
      category_id: category.id,
      amount: amount,
      description: "Expense #{random_expense_name}"
    }
    |> Repo.insert!()
  end
end
