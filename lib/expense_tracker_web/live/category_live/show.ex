defmodule ExpenseTrackerWeb.CategoryLive.Show do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Expense

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> ok()
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    category = Expenses.get_category_with_expenses!(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:category, category)
      # |> assign_budget_data(category)
      |> stream(:expenses, category.expenses)

    # Handle expense-related actions
    socket = case socket.assigns.live_action do
      :new_expense ->
        assign(socket, :expense, %Expense{category_id: String.to_integer(id)})

      :edit_expense ->
        expense = Expenses.get_expense!(params["expense_id"])
        assign(socket, :expense, expense)

      _ ->
        socket
    end

    socket |> noreply()
  end

  def handle_params(%{}, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({ExpenseTrackerWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    socket
    |> assign(:category, category)
    |> noreply()
  end

  def handle_info({ExpenseTrackerWeb.ExpenseLive.FormComponent, {:saved, _expense}}, socket) do
    # Refresh category with updated expenses
    category = Expenses.get_category_with_expenses!(socket.assigns.category.id)

    socket
    |> assign(:category, category)
    # |> assign_budget_data(category)
    |> stream(:expenses, category.expenses, reset: true)
    |> put_flash(:info, "Expense saved successfully")
    |> noreply()
  end

  @impl true
  def handle_event("delete_expense", %{"id" => id}, socket) do
    expense = Expenses.get_expense!(id)
    {:ok, _} = Expenses.delete_expense(expense)

    # Refresh category data after deletion
    category = Expenses.get_category_with_expenses!(socket.assigns.category.id)

    socket
    |> assign(:category, category)
    # |> assign_budget_data(category)
    |> stream_delete(:expenses, expense)
    |> put_flash(:info, "Expense deleted successfully")
    |> noreply()
  end

  # Helper function to calculate and assign budget-related data
  defp assign_budget_data(socket, category) do
    total_spent = calculate_total_spent(category.expenses)

    spending_percentage = if Decimal.gt?(category.monthly_budget, 0) do
      Decimal.div(total_spent, category.monthly_budget)
      |> Decimal.mult(100)
      |> Decimal.to_float()
    else
      0.0
    end

    socket
    |> assign(:total_spent, total_spent)
    |> assign(:spending_percentage, spending_percentage)
  end

  # Calculate total spent from expenses list
  defp calculate_total_spent(expenses) do
    expenses
    |> Enum.reduce(Decimal.new(0), fn expense, acc ->
      Decimal.add(acc, expense.amount)
    end)
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
  defp page_title(:new_expense), do: "New Expense"
  defp page_title(:edit_expense), do: "Edit Expense"
end
