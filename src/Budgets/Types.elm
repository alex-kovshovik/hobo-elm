module Budgets.Types exposing (..)

import Http
import Types exposing (..)


type alias BudgetId =
    RecordId


type alias Budget =
    { id : RecordId
    , name : String
    , amount : Float
    }


type alias BudgetList =
    List Budget


type alias Model =
    { budgets : List Budget
    , currentBudgetId : Maybe RecordId
    , nextBudgetId : BudgetId
    }


type Msg
    = Toggle BudgetId
    | LoadList
    | LoadListOk BudgetList
    | LoadListFail Http.Error
