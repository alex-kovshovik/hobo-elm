module Expense.State exposing (initialState, update)

import Navigation
import Time
import Date

import Types exposing (..)
import Expense.Types exposing (..)
import Expenses.Types exposing (Expense)


initialState : Model
initialState =
  let
    date = Time.millisecond |> Date.fromTime
    expense = Expense 0 0 "" "" 0.0 "" date False
  in
    Model expense ""


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    CommentInput comment ->
      ({ model | comment = comment}, Cmd.none)

    Update ->
      (model, Cmd.none)

    Cancel ->
      (model, Navigation.modifyUrl "#expenses")
