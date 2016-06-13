module Expense.Types exposing (..)

import Expenses.Types exposing (Expense)

type Msg
  = NoOp
  | CommentInput String
  | Update
  | Cancel

type alias Model = {
  expense: Expense,
  comment: String
}
