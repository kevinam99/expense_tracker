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

for i <- 1..11 do
  monthly_budget = Enum.random(100..1200) |> to_string() |> Decimal.new()
  amount = Enum.random(2..200) |> to_string() |> Decimal.new()
  category = %Category{
        description: "some description",
        monthly_budget: monthly_budget,
        name: "Category #{i}"
      }
      |> Repo.insert!()

  expenses_count = Enum.random(1..10)
  for j <- 1..expenses_count do
     %Expense{
        date: ~D[2025-07-29],
        optional_notes: "some optional_notes",
        category_id: category.id,
        amount: amount,
        description: "Expense #{j}"
      }
      |> Repo.insert!()
  end
end
