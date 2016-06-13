-- TODO: refactor to Expenses/List & Expenses/Edit
module Expenses.State exposing(initialState, update)

import Navigation
import Date exposing (Date)
import Types exposing (..)

import Expenses.Types exposing (..)
import Expenses.Rest exposing (..)
import Budgets.State as Budgets

import Utils.Numbers exposing (toFloatPoh)
import Utils.Parsers exposing (resultToObject)


initialState : Model
initialState =
  Model Budgets.initialModel [] 2 0 ""


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    AmountInput amount ->
      ({ model | amount = amount }, Cmd.none)

    BudgetList bblAction ->
      let
        (buttonData, fx) = Budgets.update user bblAction model.buttons
      in
        ({ model | buttons = buttonData }, Cmd.map BudgetList fx)

    -- adding/removing expenses
    RequestAdd ->
      let
        budgetId = Maybe.withDefault -1 model.buttons.currentBudgetId
        newExpense = Expense 0 budgetId "" "" (toFloatPoh model.amount) "" (Date.fromTime 0) False
      in
        ({ model | amount = "" }, addExpense user newExpense)

    RequestRemove expense ->
      let
        newExpenses = List.filter (\ex -> ex.id /= expense.id) model.expenses
      in
        ({ model | expenses = newExpenses}, Cmd.none)

    UpdateAdded expenseResult ->
      let
        newExpense = resultToObject expenseResult
        newExpenses = case newExpense of
          Just expense -> expense :: model.expenses
          Nothing -> model.expenses
      in
        ({ model | expenses = newExpenses}, Cmd.none)

    UpdateRemoved expenseResult ->
      let
        deletedExpense = resultToObject expenseResult

        newExpenses = case deletedExpense of
          Just expense -> List.filter (\e -> e.id /= expense.id) model.expenses
          Nothing -> model.expenses
      in
        ({ model | expenses = newExpenses }, Cmd.none)

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
