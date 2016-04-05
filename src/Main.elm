module Main where

import Html exposing (..)
import Html.Attributes exposing(..)

import StartApp.Simple as StartApp
import Signal exposing (Address)

import Components.Expenses as Expenses exposing (Expense, Model)
import Components.BudgetButton as BudgetButton

-- MODEL
initialModel : Model
initialModel =
  let
    budgetButtons = [ (1, "Grocery"), (2, "Kids"), (3, "Other") ]
    buttonList = { buttons = budgetButtons, selectedBudget = "" }
  in
    Model [ ] buttonList 2 ""


-- UPDATE
type Action
  = List Expenses.Action


update : Action -> Model -> Model
update action model =
  case action of
    List listAction -> Expenses.update listAction model


-- VIEW
view : Address Action -> Model -> Html
view address model =
  div [ class "container clear"] [
    div [ class "col-12 mt1" ] [
      Expenses.view (Signal.forwardTo address List) model
    ]
  ]

-- WIRE STUFF UP
main : Signal Html
main =
  StartApp.start {
      model = initialModel,
      update = update,
      view = view
    }
