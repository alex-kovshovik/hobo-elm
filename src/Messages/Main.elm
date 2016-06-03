module Messages.Main exposing(..)

import HttpBuilder exposing (..)

import Expenses.Types

type alias CheckData = (Float, String)

type Msg
  = List Expenses.Types.Msg
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
