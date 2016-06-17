module Urls exposing (..)

import Http

import Types exposing (..)
import Budgets.Types exposing (BudgetId)
import Expenses.Types exposing (ExpenseId)


newExpenseUrl : User -> BudgetId -> String
newExpenseUrl user budgetId =
  let
    baseUrl = user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses"
  in
    Http.url baseUrl (authParams user)


editExpenseUrl : User -> BudgetId -> ExpenseId -> String
editExpenseUrl user budgetId expenseId =
  let
    baseUrl = user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses/" ++ (toString expenseId)
  in
    Http.url baseUrl (authParams user)

expenseUrl : User -> ExpenseId -> String
expenseUrl user expenseId =
  let
    baseUrl = user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)
  in
    Http.url baseUrl (authParams user)


deleteExpenseUrl : User -> RecordId -> String
deleteExpenseUrl user expenseId =
  let
    baseUrl = user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)
  in
    Http.url baseUrl (authParams user)


budgetsUrl : User -> String
budgetsUrl user =
  Http.url (user.apiBaseUrl ++ "budgets")
    [ ("user_token", user.token),
      ("user_email", user.email) ]


deleteBudgetUrl : User -> BudgetId -> String
deleteBudgetUrl user budgetId =
  let
    baseUrl = user.apiBaseUrl ++ "budgets/" ++ (toString budgetId)
  in
    Http.url baseUrl (authParams user)


authParams : User -> List (String, String)
authParams user =
  [ ("user_token", user.token),
    ("user_email", user.email) ]
