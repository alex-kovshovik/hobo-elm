module BudgetEditor.Types exposing (..)

import HttpBuilder exposing (Error, Response)

import Budgets.Types exposing (Budget)

type Msg
  = NoOp
  | AddMore
  | InputName Int String
  | InputAmount Int String
  | Save
  | SaveOk (Result (Error (List Budget)) (Response (List Budget)))
  | Delete Int
  | DeleteOk (Result (Error (List Budget)) (Response (List Budget)))
  | Cancel
