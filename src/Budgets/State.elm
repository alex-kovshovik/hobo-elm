module Budgets.State exposing (..)

import Utils.Parsers exposing (resultToList)

import Types exposing (..)
import Budgets.Types exposing (..)

import Budgets.Rest exposing (..)


initialModel : Model
initialModel =
  { budgets = [],
    currentBudgetId = Nothing,
    nextBudgetId = -1 }


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    Toggle id ->
      let
        currentBudgetId = if Just id == model.currentBudgetId
                            then Nothing
                            else Just id
      in
        ({ model | currentBudgetId = currentBudgetId }, Cmd.none)

    Request ->
      (model, getBudgets user)

    DisplayLoaded budgetsResult ->
      ({ model | budgets = resultToList budgetsResult }, Cmd.none)

    DisplayFail budgetsResult ->
      ({ model | budgets = [] }, Cmd.none)
