module Components.BudgetButtonList where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Debug

import Components.BudgetButton as BudgetButton

-- MODEL
type alias Model = {
  buttons: List (Int, BudgetButton.Model),
  selectedBudget: String
}


-- UPDATE
type Action
  = Update Int BudgetButton.Action


update : Action -> Model -> Model
update action model =
  case action of
    Update id buttonAction ->
      let
        updateButton (buttonID, buttonModel) =
          if buttonID == id
            then (buttonID, BudgetButton.update buttonAction buttonModel)
            else (buttonID, { buttonModel | selected = False } )

        foldFunc (buttonID, buttonModel) total =
          if buttonID == id
            then total ++ buttonModel.name
            else total

      in
        { model | buttons = List.map updateButton model.buttons,
                  selectedBudget = List.foldl foldFunc "" model.buttons }


-- VIEW
viewBudgetButton: Address Action -> (Int, BudgetButton.Model) -> Html
viewBudgetButton address (id, buttonModel) =
  li [ ] [
    BudgetButton.view (Signal.forwardTo address (Update id)) buttonModel
  ]


view : Address Action -> Model -> Html
view address model =
  ul [ class "list-unstyled list-inline" ] (List.map (viewBudgetButton address) model.buttons)
