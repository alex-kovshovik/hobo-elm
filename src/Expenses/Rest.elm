module Expenses.Rest exposing (getExpenses, addExpense, deleteExpense)

import Http
import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing((:=))
import Json.Encode
import Date

import Types exposing (..)
import Expenses.Types exposing (..)
import Budgets.Types exposing (BudgetId)

import Utils.Numbers exposing (toFloatPoh, formatAmount)

getExpenses : User -> Int -> Cmd Msg
getExpenses user weekNumber =
  get (expensesUrl user weekNumber)
    |> withHeader "Content-Type" "application/json"
    |> send (jsonReader decodeExpenses) (jsonReader decodeExpenses)
    |> Task.toResult
    |> Task.perform UpdateList UpdateList


addExpense : User -> Expense -> Cmd Msg
addExpense user expense =
  let
    expenseJson = Json.Encode.object [
      ("expense", Json.Encode.object [
        ("amount", Json.Encode.float expense.amount)
      ])
    ]
  in
    post (expenseUrl user expense.budgetId)
      |> withHeader "Content-Type" "application/json"
      |> withJsonBody expenseJson
      |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
      |> Task.toResult
      |> Task.perform UpdateAdded UpdateAdded


deleteExpense : User -> RecordId -> Cmd Msg
deleteExpense user expenseId =
  delete (deleteExpenseUrl user expenseId)
    |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
    |> Task.toResult
    |> Task.perform UpdateRemoved UpdateRemoved


expensesUrl : User -> Int -> String
expensesUrl user weekNumber =
  let
    params = ("week", toString weekNumber)::(authParams user)
  in
    Http.url (user.apiBaseUrl ++ "expenses") params


expenseUrl : User -> BudgetId -> String
expenseUrl user budgetId =
  let
    baseUrl = user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses"
  in
    Http.url baseUrl (authParams user)


deleteExpenseUrl : User -> RecordId -> String
deleteExpenseUrl user expenseId =
  let
    baseUrl = user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)
  in
    Http.url baseUrl (authParams user)


authParams : User -> List (String, String)
authParams user =
  [ ("user_token", user.token),
    ("user_email", user.email) ]


-- DECODERS
decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
  Json.at ["expenses"] (Json.list decodeExpenseFields)


decodeExpense : Json.Decoder Expense
decodeExpense =
  Json.at ["expense"] decodeExpenseFields


decodeExpenseFields : Json.Decoder Expense
decodeExpenseFields =
  Json.object6 convertDecoding
    ( "id"              := Json.int )
    ( "budget_id"       := Json.int )
    ( "budget_name"     := Json.string )
    ( "created_by_name" := Json.string )
    ( "amount"          := Json.string )
    ( "created_at"      := Json.string )


convertDecoding : RecordId -> RecordId -> String -> String -> String -> String -> Expense
convertDecoding id budgetId budgetName createdByName amount createdAtString  =
  let
    dateResult = Date.fromString createdAtString
    createdAt = case dateResult of
                  Ok date -> date
                  Err error -> Date.fromTime 0
  in
    Expense id budgetId budgetName createdByName (toFloatPoh amount) "" createdAt False
