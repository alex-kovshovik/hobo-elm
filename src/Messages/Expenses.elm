module Messages.Expenses exposing(..)

import Messages.BudgetButtonList as BBL
import Records exposing(Expense, RecordId)
import Http
import HttpBuilder exposing (..)

type Msg
  = AmountInput String
  | BudgetList BBL.Msg

  -- adding/removing expenses
  | RequestAdd
  | RequestRemove Expense
  | UpdateAdded (Result (Error Expense) (Response Expense))
  | UpdateRemoved (Result (Error Expense) (Response Expense))

  -- loading and displaying the list
  | RequestList
  | UpdateList (Result Http.Error (List Expense))

  -- navigating between weeks
  | LoadPreviousWeek
  | LoadNextWeek
