module App.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html exposing(map)

import App.Types exposing (..)

import Expense.View
import Expenses.View
import Routes exposing (..)


root : Model -> Html Msg
root model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      pages model
    ]
  ]


pages : Model -> Html Msg
pages model =
  case model.route of
    ExpensesRoute ->
      map List (Expenses.View.root model.user model.data)

    ExpenseRoute expenseId ->
      map Edit (Expense.View.root model.user model.data.expenses expenseId)

    BudgetsRoute ->
      text "List of budgets route"

    BudgetRoute budgetId ->
      text "One budget route"

    NotFoundRoute ->
      text "404 Not Found"
