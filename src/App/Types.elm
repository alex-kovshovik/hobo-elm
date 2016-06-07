module App.Types exposing (..)

import HttpBuilder exposing (..)

import Routes exposing (Route)
import Types exposing (..)
import Expenses.Types as Expenses
import Expense.Types as Expense

type alias CheckData = (Float, String)

type alias Model = {
  data: Expenses.Model,
  editData: Expense.Model,
  user: User,
  route: Route
}

type Msg
  = List Expenses.Msg
  | Edit Expense.Msg
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
