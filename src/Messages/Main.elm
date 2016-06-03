module Messages.Main exposing(..)

import HttpBuilder exposing (..)

import Messages.Expenses

type alias CheckData = (Float, String)

type Msg
  = List Messages.Expenses.Msg
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
