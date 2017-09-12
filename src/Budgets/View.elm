module Budgets.View exposing (root)

import Budgets.Button.View as BudgetButton
import Budgets.Types exposing (..)
import Expenses.List.Types exposing (Expense)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)


root : User -> Int -> List Expense -> Model -> Html Msg
root user monthNumber expenses model =
    div [ class "clear mt1" ] (List.map (budgetButton user monthNumber expenses model) model.budgets)


budgetButton : User -> Int -> List Expense -> Model -> Budget -> Html Msg
budgetButton user monthNumber expenses model budget =
    div [ class "col-4 mb05" ]
        [ BudgetButton.root user monthNumber model.currentBudgetId (onClick (Toggle budget.id)) budget expenses
        ]
