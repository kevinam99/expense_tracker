# Expense Tracker - A Phoenix LiveView project

## Approach to handling money/currency
Money can't be handled like normal numbers. Precision matters. I used the `Decimal` type to store and work with the numbers. For displaying them, I used the `Number` package to display in the appropriate currency format. I chose the USD as the currency

### Negative amounts
Negative amounts are handled within the form validation.

### Multi currency
To handle multiple currencies, there could be two ways
- have a setting `currency` to allow picking any one currency that will apply to ALL expenses
- allow currency setting for each expense having any one as the default. Consequently, the progress chart would have to be shown for each currency and perhaps, also have budget for every currency which could get messy.
- I would also update to having currency based separators and delimiters. For example, in most parts of the world, the decimal point is used to denote sub zero currency amount and the comma is used for showing thousands, millions etc. In Europe, the convention is the opposite. The Indian number system doesn't have the million, so the placement of the comma changes. 
So these edge cases would have to be considered when adding multiple currency support. Or there can be a setting for this to help keep things simple.

## Architectural decisions made
I decided to have a main context `Expense` which has cateogries and expenses.
I allowed expense tracking for future dates so that known future expenses can already be tracked immediately.

### Overspending
When a category's budget is overspent, the progress bar turns red with a message showing the exact amount by which the budget is exceeded.

I still allow the expenses to be added because disallowing it doesn't change the fact that an expense occurred

## UX decisions 
While I list the recent expenses first, I didn't apply a specific sorting for the categories. The reason being that it is a high-level parameter and requires to be at the same position when a user wants to perform analysis. It would be terrible UX if the position of the categories changes with the expenses.

## Trade-offs or shortcuts taken due to time constraints
I decided to write tests with AI - at least the LiveView tests. Since I am primarily a backend developer, I used the generators in Phoenix to generate the frontend components to spend minimum time in styling them myself

I didn't add a `monthly budget reset logic` because it's similar to edit/delete operations in that, that there is a modification done in that budget

This is also a single user application so all expenses are not tied to specific persons.

## Testing strategy
I wrote tests for contexts, schemas and the LiveViews. Tested for real time updates especially with the budget progress to validate that it updates in real-time

## Bonus points achieved
- [x] Add category types (e.g., Food, Transportation, Entertainment) via seeds
- [x] Implement spending limits or alerts when approaching budget
- [x] Add basic styling with Tailwind CSS via Phoenix generator
- [ ] Handle monthly budget reset logic
