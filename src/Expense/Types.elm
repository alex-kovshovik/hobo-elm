module Expense.Types exposing (..)

import Expenses.Types exposing (ExpenseId)

type Msg
  = Show
  | Edit
  | Update

type alias Model = {
  expenseId: ExpenseId
}
