defmodule ExpenseTrackerWeb.ExpenseLive.Show do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"expense_id" => id}, _, socket) do
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:expense, Expenses.get_expense!(id))
     |> noreply()
  end

  defp page_title(:show), do: "Show Expense"
  defp page_title(:edit), do: "Edit Expense"
end
