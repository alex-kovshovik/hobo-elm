-- TODO: refactor to Expenses/List & Expenses/Edit
module Expenses.State exposing(initialState, update)

import Navigation
import Date exposing (Date)
import Types exposing (..)

import Expenses.Types exposing (..)
import Expenses.Rest exposing (..)
import Budgets.State as Budgets
import Budgets.Types exposing (BudgetId)

import Utils.Numbers exposing (toFloatPoh)
import Utils.Parsers exposing (resultToObject)


initialState : Model
initialState =
  { buttons = Budgets.initialModel,
    expenses = [],
    weekNumber = 0,
    amount = "" }


getNewExpenseCmd : User -> Float -> BudgetId -> Cmd Expenses.Types.Msg
getNewExpenseCmd user amount budgetId =
  let
    newExpense =
      {
        id = 0,
        budgetId = budgetId,
        budgetName = "",
        createdByName = "",
        amount = amount,
        comment = "",
        createdAt = Date.fromTime 0
      }
  in
    addExpense user newExpense


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    AmountInput amount ->
      let
        buttons = model.buttons
        newButtons = { buttons | currentBudgetId = Nothing }
      in
        ({ model | buttons = newButtons, amount = amount }, Cmd.none)

    BudgetList bblAction ->
      let
        (buttonData, bblCmd, (addNew, budgetId)) = Budgets.update user bblAction model.buttons
        floatAmount = toFloatPoh model.amount

        (newAmount, addExpenseCmd) =
          if addNew && floatAmount > 0.0
            then ("", getNewExpenseCmd user floatAmount budgetId)
            else (model.amount, Cmd.none)

        cmd = Cmd.batch [
          Cmd.map BudgetList bblCmd,
          addExpenseCmd
        ]

      in
        ({ model | amount = newAmount, buttons = buttonData }, cmd)

    UpdateAdded expenseResult ->
      let
        newExpense = resultToObject expenseResult
        newExpenses = case newExpense of
          Just expense -> expense :: model.expenses
          Nothing -> model.expenses

        buttons = model.buttons
        newButtons = { buttons | currentBudgetId = Nothing }
      in
        ({ model | buttons = newButtons, expenses = newExpenses}, Cmd.none)

    -- showing/editing expenses
    Show expense ->
      (model, Navigation.modifyUrl ("#expenses/" ++ (toString expense.id)) )

    -- loading and displaying the list
    RequestList ->
      (model, getExpenses user model.weekNumber)

    UpdateList expensesResult ->
      let
        expensesObject = resultToObject expensesResult
        expenses = case expensesObject of
          Just list -> list
          Nothing -> []
      in
        ({ model | expenses = expenses}, Cmd.none)

    -- navigating between weeks
    LoadPreviousWeek ->
      let
        weekNumber = model.weekNumber - 1
      in
        ({ model | weekNumber = weekNumber }, getExpenses user weekNumber)

    LoadNextWeek ->
      let
        weekNumber = if model.weekNumber < 0 then model.weekNumber + 1 else model.weekNumber
      in
        ({ model | weekNumber = weekNumber }, getExpenses user weekNumber)
