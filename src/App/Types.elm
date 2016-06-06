module App.Types exposing (..)

import HttpBuilder exposing (..)

import Routes exposing (Route)
import Types exposing (..)
import Expenses.Types as Expenses

type alias CheckData = (Float, String)

type alias Model = {
  data: Expenses.Model,
  user: User,
  route: Route
}

type Msg
  = List Expenses.Msg
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
