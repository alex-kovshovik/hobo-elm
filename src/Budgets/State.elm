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


update : User -> Msg -> Model -> (Model, Cmd Msg, (Bool, BudgetId))
update user msg model =
  case msg of
    Toggle id ->
      let
        (budgetId, addNew) =
          if Just id == model.currentBudgetId
            then (Nothing, False)
            else (Just id, True)
      in
        ({ model | currentBudgetId = budgetId }, Cmd.none, (addNew, id))

    Request ->
      (model, getBudgets user, (False, 0))

    DisplayLoaded budgetsResult ->
      ({ model | budgets = resultToList budgetsResult }, Cmd.none, (False, 0))

    DisplayFail budgetsResult ->
      ({ model | budgets = [] }, Cmd.none, (False, 0))
