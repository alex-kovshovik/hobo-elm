module Expenses.Edit.Types exposing (..)

import HttpBuilder exposing (Error, Response)
import Expenses.List.Types exposing (Expense)


type Msg
    = NoOp
    | CommentInput String
    | LoadOk (Result (Error Expense) (Response Expense))
    | LoadFail (Result (Error Expense) (Response Expense))
    | Update
    | UpdateOk (Result (Error Expense) (Response Expense))
    | UpdateFail (Result (Error Expense) (Response Expense))
    | Delete
    | DeleteOk (Result (Error Expense) (Response Expense))
    | Cancel


type alias Model =
    { expense : Expense
    , comment : String
    , error : String
    }
