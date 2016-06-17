module App.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.App as Html exposing(map)

import App.Types exposing (..)

import Expense.View
import Expenses.View
import BudgetEditor.View
import Routes exposing (..)


root : Model -> Html Msg
root model =
  div [ class "container"] [
    div [ class "mt1" ] [
      div [ class "col-6" ] [
        text ("Welcome " ++ model.user.email)
      ],
      div [ class "col-6", style [("text-align", "right")] ] [
        a [ onClick EditBudgets ] [ text "Budgets" ],
        text " | ",
        a [ onClick Logout ] [ text "Logout" ]
      ],
      br [ ] [ ],
      br [ ] [ ]
    ],

    div [ ] [
      pages model
    ]
  ]


pages : Model -> Html Msg
pages model =
  case model.route of
    ExpensesRoute ->
      map List (Expenses.View.root model.user model.data)

    ExpenseRoute expenseId ->
      map Edit (Expense.View.root model.user model.editData)

    BudgetsRoute ->
      map BudgetEditor (BudgetEditor.View.root model.user model.data.buttons)

    -- BudgetRoute budgetId ->
    --   text "One budget route"
    --
    NotFoundRoute ->
      text "404 Not Found"
