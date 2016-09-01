module Budgets.Types exposing (..)

import HttpBuilder exposing (Error, Response)
import Types exposing(..)

type alias BudgetId = RecordId

type alias Budget = {
  id : RecordId,
  name : String,
  amount : Float
}

type alias BudgetList = List Budget

type alias Model = {
  budgets : List Budget,
  currentBudgetId : Maybe RecordId, -- one or none can be selected.
  nextBudgetId : BudgetId -- Only used for budget editing, negative numbers.
}

type Msg
  = Toggle BudgetId
  | Request
  | DisplayLoaded (Result (Error BudgetList) (Response BudgetList))
