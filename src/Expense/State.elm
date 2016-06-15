module Expense.State exposing (initialState, update)

import Navigation
import Time
import Date
import Platform.Cmd exposing (map)

import Utils.Parsers exposing(resultToObject)

import Types exposing (..)
import Expense.Types exposing (..)
import Expenses.Types as Expenses

import Expense.Rest exposing(..)


emptyExpense : Expenses.Expense
emptyExpense =
  let
    pohDate = Time.millisecond |> Date.fromTime
  in
    Expenses.Expense 0 0 "" "" 0.0 "" pohDate False

initialState : Model
initialState =
  Model emptyExpense "" ""


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    CommentInput comment ->
      ({ model | comment = comment}, Cmd.none)

    LoadOk result ->
      let
        expense = resultToObject result |> Maybe.withDefault (emptyExpense)
        _ = Debug.log "loaded expense" expense
      in
        ({ model | expense = expense, comment = expense.comment}, Cmd.none)

    LoadFail result ->
      ({ model | error = "Error loading the expense"}, Cmd.none)

    Update ->
      let
        e = model.expense
        expense = { e | comment = model.comment }
      in
        (model, updateExpense user expense)

    UpdateOk result ->
      (model, Navigation.modifyUrl "#expenses")

    UpdateFail result ->
      ({ model | error = "Error saving the expense"}, Cmd.none)

    Delete ->
      (model, deleteExpense user model.expense.id)

    DeleteOk result ->
      (model, Navigation.modifyUrl "#expenses")

    Cancel ->
      (model, Navigation.modifyUrl "#expenses")
