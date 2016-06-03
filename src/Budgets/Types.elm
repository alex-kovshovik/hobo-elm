module Budgets.Types exposing (..)

import Http exposing(Error)
import Types exposing(..)

type alias BudgetId = RecordId

type alias Budget = {
  id : RecordId,
  name : String,
  amount : Float
}

type alias Model = {
  budgets : List Budget,
  currentBudgetId : Maybe RecordId -- one or none can be selected.
}

type Msg
  = Toggle BudgetId
  | Request
  | DisplayLoaded (Result Error (List Budget))
  | DisplayFail (Result Error (List Budget))
