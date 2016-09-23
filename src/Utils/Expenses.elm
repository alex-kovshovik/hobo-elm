module Utils.Expenses exposing (getTotal)

import Expenses.Types exposing (Expense)


getTotal : List Expense -> Float
getTotal expenses =
    List.foldl (\ex sum -> sum + ex.amount) 0.0 expenses
