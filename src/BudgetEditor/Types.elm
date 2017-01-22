module BudgetEditor.Types exposing (..)

import Http
import Budgets.Types exposing (Budget)


type Msg
    = NoOp
    | AddMore
    | InputName Int String
    | InputAmount Int String
    | Save
    | SaveOk (List Budget)
    | SaveFail Http.Error
    | Delete Int
    | DeleteOk String
    | DeleteFail Http.Error
    | Cancel
