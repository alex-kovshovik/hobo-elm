module Components.BudgetButtonList where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)

import Records exposing (Budget, RecordId)
import Components.BudgetButton as BudgetButton

-- MODEL
type alias Model = {
  budgets : List Budget,
  currentBudget : Maybe Budget -- one or none can be selected.
}


-- UPDATE
type Action = Toggle RecordId


update : Action -> Model -> Model
update action model =
  case action of
    Toggle id ->
      let
        clickedBudgets = List.filter (\budget -> budget.id == id) model.budgets
        clickedBudget = List.head clickedBudgets

        currentBudget = if model.currentBudget == clickedBudget
                          then Nothing
                          else clickedBudget
      in
        { model | currentBudget = currentBudget }


-- VIEW
viewBudgetButton: Address Action -> Model -> Budget -> Html
viewBudgetButton address model budget =
  li [ ] [
    BudgetButton.view model.currentBudget (onClick address (Toggle budget.id)) budget
  ]


view : Address Action -> Model -> Html
view address model =
  ul [ class "list-unstyled list-inline" ] (List.map (viewBudgetButton address model) model.budgets)
