defmodule ExpenseTrackerWeb.CategoryLiveTest do
  use ExpenseTrackerWeb.ConnCase
  import Phoenix.LiveViewTest
  import ExpenseTracker.ExpensesFixtures

  @create_attrs %{name: "some name", description: "some description", monthly_budget: "120.5"}
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    monthly_budget: "456.7"
  }
  @invalid_attrs %{name: nil, description: nil, monthly_budget: nil}

  @expense_attrs %{
    description: "Test expense",
    amount: "50.25",
    date: "2024-01-15",
    optional_notes: "Test notes"
  }

  defp create_category(_) do
    category = category_fixture()
    %{category: category}
  end

  defp create_category_with_expenses(_) do
    category = category_fixture(@create_attrs)
    expense1 = expense_fixture(%{category_id: category.id, amount: "30.50"})
    expense2 = expense_fixture(%{category_id: category.id, amount: "25.75"})
    %{category: category, expenses: [expense1, expense2]}
  end

  describe "Index" do
    setup [:create_category]

    test "lists all categories", %{conn: conn, category: category} do
      {:ok, _index_live, html} = live(conn, ~p"/categories")
      assert html =~ "Listing Categories"
      assert html =~ category.name
    end

    test "saves new category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "Category #{@create_attrs.name} created successfully"
      assert html =~ "some name"
    end

    test "updates category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "Category #{@update_attrs.name} updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")
      assert index_live |> element("#categories-#{category.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#categories-#{category.id}")
    end
  end

  describe "Show" do
    setup [:create_category]

    test "displays category", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")
      assert html =~ "Show Category"
      assert html =~ category.name
    end

    test "updates category within modal", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(show_live, ~p"/categories/#{category}/show/edit")

      assert show_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#category-form", category: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/categories/#{category}")

      html = render(show_live)
      assert html =~ "Category #{@update_attrs.name} updated successfully"
      assert html =~ "some updated name"
    end

    test "displays budget progress section", %{conn: conn, category: category} do
      {:ok, show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "Budget Progress"
      assert html =~ "$0.00 of"
      assert html =~ "0.0% used"
      assert has_element?(show_live, ".bg-green-500")
    end

    test "shows empty state when no expenses", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "No expenses yet"
      assert html =~ "Get started by creating your first expense"
      assert html =~ "Add your first expense"
    end
  end

  describe "Show with expenses" do
    setup [:create_category_with_expenses]

    test "displays expenses in table", %{conn: conn, category: category, expenses: expenses} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      Enum.each(expenses, fn expense ->
        assert html =~ expense.description
        assert html =~ "$#{expense.amount}"
      end)

      assert html =~ "Description"
      assert html =~ "Amount"
      assert html =~ "Date"
      assert html =~ "Notes"
    end

    test "calculates and displays correct budget progress", %{conn: conn, category: category} do
      {:ok, show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "$56.25 of $120.50 spent"
      assert html =~ "46.7% used"

      assert has_element?(show_live, ".bg-green-500")
      refute has_element?(show_live, ".bg-yellow-500")
      refute has_element?(show_live, ".bg-red-500")
    end

    test "shows yellow progress bar when spending is 80-99%", %{conn: conn} do
      category = category_fixture(%{monthly_budget: "70.00"})
      expense_fixture(%{category_id: category.id, amount: "30.50"})
      expense_fixture(%{category_id: category.id, amount: "25.75"})

      {:ok, show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "80.4% used"
      assert has_element?(show_live, ".bg-yellow-500")
      refute has_element?(show_live, ".bg-green-500")
      refute has_element?(show_live, ".bg-red-500")
    end

    test "shows red progress bar and warning when budget exceeded", %{conn: conn} do
      category = category_fixture(%{monthly_budget: "50.00"})
      expense_fixture(%{category_id: category.id, amount: "30.50"})
      expense_fixture(%{category_id: category.id, amount: "25.75"})

      {:ok, show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "112.5% used"
      assert html =~ "⚠️ Budget exceeded (-$6.25)!"
      assert has_element?(show_live, ".bg-red-500")
      refute has_element?(show_live, ".bg-green-500")
      refute has_element?(show_live, ".bg-yellow-500")
    end

    test "deletes expense and updates budget calculations", %{
      conn: conn,
      category: category,
      expenses: [expense1, _expense2]
    } do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert render(show_live) =~ "$56.25 of $120.50 spent"
      assert render(show_live) =~ "46.7% used"

      delete_selector = "#expenses-#{expense1.id} a[data-confirm='Are you sure?']"

      assert show_live
             |> element(delete_selector)
             |> render_click()

      html = render(show_live)
      assert html =~ "$25.75 of $120.50 spent"
      assert html =~ "21.4% used"
      assert html =~ "Expense deleted successfully"
    end
  end

  describe "Expense management" do
    setup [:create_category]

    test "opens new expense modal", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live |> element("a", "New Expense") |> render_click() =~ "New Expense"
      assert_patch(show_live, ~p"/categories/#{category.id}/expenses/new")
      assert has_element?(show_live, "#expense-modal")
    end

    test "creates new expense and updates budget", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      show_live |> element("a", "New Expense") |> render_click()

      assert show_live
             |> form("#expense-form", expense: @expense_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/categories/#{category}")

      html = render(show_live)
      assert html =~ @expense_attrs.description
      assert html =~ "$50.25 of $120.50 spent"
      assert html =~ "41.7% used"
      assert html =~ "Expense saved successfully"
    end

    test "opens edit expense modal with existing data", %{conn: conn} do
      category = category_fixture()
      expense = expense_fixture(%{category_id: category.id, description: "Original expense"})

      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live |> element("a[href*='/expenses/#{expense.id}/edit']") |> render_click() =~
               "Edit Expense"

      assert_patch(show_live, ~p"/categories/#{category.id}/expenses/#{expense.id}/edit")
      assert has_element?(show_live, "#expense-modal")

      assert has_element?(show_live, "input[value='Original expense']")
    end

    test "validates expense form", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      show_live |> element("a", "New Expense") |> render_click()

      assert show_live
             |> form("#expense-form", expense: %{description: "", amount: ""})
             |> render_change() =~ "can&#39;t be blank"
    end
  end

  describe "Currency formatting" do
    setup [:create_category]

    test "formats currency correctly in budget display", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "$120.50"
    end

    test "formats decimal amounts correctly", %{conn: conn} do
      category = category_fixture(%{monthly_budget: "1000.00"})
      expense_fixture(%{category_id: category.id, amount: "123.45"})
      expense_fixture(%{category_id: category.id, amount: "67.89"})

      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "$123.45"
      assert html =~ "$67.89"

      assert html =~ "$191.34 of $1,000.00 spent"
    end

    test "handles large currency amounts", %{conn: conn} do
      category = category_fixture(%{monthly_budget: "10000.00"})
      expense_fixture(%{category_id: category.id, amount: "5432.10"})

      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "$5,432.10"
      assert html =~ "$10,000.00"
    end
  end

  describe "Real-time updates" do
    setup [:create_category_with_expenses]

    test "budget updates immediately after expense deletion", %{
      conn: conn,
      category: category,
      expenses: [expense1, _expense2]
    } do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert render(show_live) =~ "46.7% used"

      show_live
      |> element("#expenses-#{expense1.id} a[data-confirm='Are you sure?']")
      |> render_click()

      assert render(show_live) =~ "21.4% used"
    end

    test "expense list updates when expense is deleted", %{conn: conn} do
      category = category_fixture(@create_attrs)

      expense1 =
        expense_fixture(%{
          category_id: category.id,
          amount: "30.50",
          description: "a desctiption"
        })

      expense2 =
        expense_fixture(%{
          category_id: category.id,
          amount: "25.75",
          description: "another desctiption"
        })

      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert render(show_live) =~ expense1.description
      assert render(show_live) =~ expense2.description

      show_live
      |> element("#expenses-#{expense1.id} a[data-confirm='Are you sure?']")
      |> render_click()

      refute render(show_live) =~ expense1.description
      assert render(show_live) =~ expense2.description
    end
  end
end
