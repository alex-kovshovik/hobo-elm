module Budgets.View exposing(root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Types exposing (..)
import Budgets.Types exposing (..)
import Expenses.Types exposing (Expense)

import Budgets.Button.View as BudgetButton


root : User -> Int -> List Expense -> Model -> Html Msg
root user weekNumber expenses model =
  div [ class "clear mt1" ] (List.map (budgetButton user weekNumber expenses model) model.budgets)


budgetButton: User -> Int -> List Expense -> Model -> Budget -> Html Msg
budgetButton user weekNumber expenses model budget =
  div [ class "col-4 mb05" ] [
    BudgetButton.root user weekNumber model.currentBudgetId (onClick (Toggle budget.id)) budget expenses
  ]
