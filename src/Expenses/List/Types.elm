module Expenses.List.Types exposing (..)

import Date exposing (Date)
import Types exposing (..)
import Http
import Budgets.Types as Budgets


type alias ExpenseId =
    RecordId


type alias Expense =
    { id : ExpenseId
    , budgetId : RecordId
    , budgetName : String
    , createdByName : String
    , amount : Float
    , comment : String
    , createdAt : Date
    }


type alias ExpenseList =
    List Expense


type alias Model =
    { buttons : Budgets.Model
    , expenses : ExpenseList
    , weekNumber : Int
    , -- relative number of week, 0 (zero) means current
      -- form
      amount : String
    }


type Msg
    = AmountInput String
    | BudgetList Budgets.Msg
      -- adding/removing expenses
    | UpdateAddedOk Expense
    | UpdateAddedFail Http.Error
      -- showing/editing expenses
    | Show Expense
      -- loading and displaying the list
    | LoadList
    | LoadListOk ExpenseList
    | LoadListFail Http.Error
      -- navigating between weeks
    | LoadPreviousWeek
    | LoadNextWeek
