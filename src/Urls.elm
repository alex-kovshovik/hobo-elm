module Urls exposing (..)

import HttpBuilder exposing (..)
import Types exposing (..)
import Budgets.Types exposing (BudgetId)
import Expenses.List.Types exposing (ExpenseId)


newExpenseUrl : User -> BudgetId -> String
newExpenseUrl user budgetId =
    user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses"


editExpenseUrl : User -> BudgetId -> ExpenseId -> String
editExpenseUrl user budgetId expenseId =
    user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses/" ++ (toString expenseId)


expenseUrl : User -> ExpenseId -> String
expenseUrl user expenseId =
    user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)


deleteExpenseUrl : User -> RecordId -> String
deleteExpenseUrl user expenseId =
    user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)


budgetsUrl : User -> String
budgetsUrl user =
    user.apiBaseUrl ++ "budgets"


deleteBudgetUrl : User -> BudgetId -> String
deleteBudgetUrl user budgetId =
    user.apiBaseUrl ++ "budgets/" ++ (toString budgetId)


withAuthHeader : User -> (RequestBuilder -> RequestBuilder)
withAuthHeader user =
    let
        auth =
            "Token token=\"" ++ user.token ++ "\", email=\"" ++ user.email ++ "\""
    in
        withHeader "Authorization" auth
