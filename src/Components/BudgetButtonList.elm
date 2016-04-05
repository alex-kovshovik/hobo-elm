module Components.BudgetButtonList where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Debug

import Components.BudgetButton as BudgetButton

-- MODEL
type alias Model = {
  buttons: List (Int, String),
  selectedBudget: String
}

-- UPDATE
type Action = Toggle Int


update : Action -> Model -> Model
update action model =
  case action of
    Toggle id ->
      let
        getSelectedBudget (buttonID, budgetName) result =
          if buttonID == id then result ++ budgetName else result
      in
        { model | selectedBudget = List.foldl getSelectedBudget "" model.buttons }


-- VIEW
viewBudgetButton: Address Action -> Model -> (Int, String) -> Html
viewBudgetButton address model (id, buttonModel) =
  li [ ] [
    BudgetButton.view model.selectedBudget (onClick address (Toggle id)) buttonModel
  ]


view : Address Action -> Model -> Html
view address model =
  ul [ class "list-unstyled list-inline" ] (List.map (viewBudgetButton address model) model.buttons)
