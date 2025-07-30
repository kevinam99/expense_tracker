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

category_expense_names =
  %{
    "Food" => [
      "Groceries", "Restaurant Dinner", "Coffee Shop", "Lunch Out", "Snacks",
      "Takeaway", "Breakfast", "Bakery Items", "Smoothie", "Catering"
    ],
    "Transportation" => [
      "Fuel", "Public Transport Pass", "Taxi Ride", "Ride-share", "Parking Fee",
      "Car Maintenance", "Toll Charges", "Flight Ticket", "Bus Fare", "Train Ticket"
    ],
    "Entertainment" => [
      "Movie Tickets", "Concert", "Streaming Service Subscription", "Video Game Purchase",
      "Museum Entry", "Book Purchase", "Sporting Event", "Theme Park Ticket", "Board Game",
      "Live Show"
    ]
  }


for category_name <- Map.keys(category_expense_names) do
  monthly_budget = Enum.random(100..1200) |> to_string() |> Decimal.new()

  category =
    %Category{
      description: "Some description for #{category_name} category.",
      monthly_budget: monthly_budget,
      name: category_name
    }
    |> Repo.insert!()

  expenses_count = Enum.random(1..10)

  relevant_expense_names = category_expense_names[category_name]

  for _ <- 1..expenses_count do
    expense_description = Enum.random(relevant_expense_names) || "Miscellaneous Expense"
    amount = Enum.random(2..200) |> to_string() |> Decimal.new()
    %Expense{
      date: Date.add(Date.utc_today(), Enum.random(-365..365)),
      optional_notes: "Some optional notes for #{expense_description}.",
      category_id: category.id,
      amount: amount,
      description: expense_description
    }
    |> Repo.insert!()
  end
end
