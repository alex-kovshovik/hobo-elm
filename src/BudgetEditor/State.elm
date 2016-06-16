module BudgetEditor.State exposing (update)

import Navigation

import Types exposing (..)
import Budgets.Types exposing (Model)
import BudgetEditor.Types exposing (..)


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    Cancel ->
      (model, Navigation.modifyUrl "#expenses")
