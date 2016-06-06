module App.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html exposing(map)

import App.Types exposing (..)

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
      text "Not implemented"

    BudgetsRoute ->
      text "Not implemented"

    BudgetRoute budgetId ->
      text "Not implemented"

    NotFoundRoute ->
      text "404 Not Found"
