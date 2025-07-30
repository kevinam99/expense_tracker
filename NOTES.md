# Expense Tracker - A Phoenix LiveView project

## Approach to handling money/currency
Money can't be handled like normal numbers. Precision matters. I used the `Decimal` type to store the numbers. For displaying them, I used the `Number` package to display in the appropriate currency format

## Describe any architectural decisions you made
I decided to have a main context `Expense` which has cateogries and expenses.

## Note any trade-offs or shortcuts taken due to time constraints
I decided to write tests with AI - at least the LiveView tests. Since I am primarily a backend developer, I used the generators in Phoenix to generate the frontend components to spend minimum time in styling them myself

## Explain your testing strategy
I wrote tests for contexts, schemas and the LiveViews. Tested for real time updates especially with the budget progress to validate that it updates in real-time