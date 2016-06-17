module BudgetEditor.State exposing (update)

import Navigation

import Utils.Numbers exposing (toFloatPoh)
import Utils.Parsers exposing (resultToObject)

import Types exposing (..)
import Budgets.Types exposing (Model, Budget)
import BudgetEditor.Types exposing (..)
import BudgetEditor.Rest exposing (saveBudgets)


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    AddMore ->
      let
        newBudget = emptyBudget model.nextBudgetId
      in
        ({ model | nextBudgetId = model.nextBudgetId - 1,
                   budgets = List.append model.budgets [newBudget] },
        Cmd.none)

    InputName id name ->
      let
        _ = Debug.log "InputName" (id, name)

        modifyBudgetName id name budget =
          if id == budget.id then { budget | name = name } else budget

        budgets = List.map (modifyBudgetName id name) model.budgets
      in
        ({ model | budgets = budgets }, Cmd.none)

    InputAmount id amount ->
      let
        modifyBudgetAmount id amount budget =
          if id == budget.id then { budget | amount = toFloatPoh amount } else budget

        budgets = List.map (modifyBudgetAmount id amount) model.budgets
      in
        ({ model | budgets = budgets }, Cmd.none)

    Save ->
      (model, saveBudgets user model.budgets)

    SaveOk result ->
      let
        maybeBudgets = resultToObject result
        budgets = case maybeBudgets of
          Just b -> b
          Nothing -> model.budgets
      in
        ({ model | budgets = budgets }, Navigation.modifyUrl "#expenses")

    Delete budgetId ->
      (model, Cmd.none) -- TODO: to be continued!

    DeleteOk result ->
      (model, Cmd.none)

    Cancel ->
      (model, Navigation.modifyUrl "#expenses")


emptyBudget : Int -> Budget
emptyBudget budgetId =
  Budget budgetId "" 300.0
