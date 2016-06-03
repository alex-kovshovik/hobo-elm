module App.Types exposing (..)

import HttpBuilder exposing (..)

import Types exposing (..)
import Expenses.Types

type alias CheckData = (Float, String)

type alias Model = {
  data: Expenses.Types.Model,
  user: User
}

type Msg
  = List Expenses.Types.Msg
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
