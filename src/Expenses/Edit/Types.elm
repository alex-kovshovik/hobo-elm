module Expenses.Edit.Types exposing (..)

import Http
import Expenses.List.Types exposing (Expense)


type Msg
    = CommentInput String
    | LoadOk Expense
    | LoadFail Http.Error
    | Update
    | UpdateOk Expense
    | UpdateFail Http.Error
    | Delete
    | DeleteOk Expense
    | DeleteFail Http.Error
    | Cancel


type alias Model =
    { expense : Expense
    , comment : String
    , error : String
    }
