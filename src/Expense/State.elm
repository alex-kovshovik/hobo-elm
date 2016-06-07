module Expense.State exposing (initialState, update)

import Types exposing (..)
import Expense.Types exposing (..)

initialState : Model
initialState =
  Model 0


update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  (model, Cmd.none)
