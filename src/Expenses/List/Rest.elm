module Expenses.List.Rest exposing (getExpenses, getNewExpenseCmd)

import Http
import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing ((:=))
import Json.Encode
import Date
import Urls exposing (..)
import Types exposing (..)
import Expenses.List.Types exposing (..)
import Budgets.Types exposing (BudgetId)
import Utils.Numbers exposing (toFloatPoh, formatAmount)


getExpenses : User -> Int -> Cmd Msg
getExpenses user weekNumber =
    get (expensesUrl user weekNumber)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> send (jsonReader decodeExpenses) (jsonReader decodeExpenses)
        |> Task.toResult
        |> Task.perform UpdateList UpdateList


getNewExpenseCmd : User -> Float -> BudgetId -> Cmd Expenses.List.Types.Msg
getNewExpenseCmd user amount budgetId =
    let
        newExpense =
            { id = 0
            , budgetId = budgetId
            , budgetName = ""
            , createdByName = ""
            , amount = amount
            , comment = ""
            , createdAt = Date.fromTime 0
            }
    in
        addExpense user newExpense


addExpense : User -> Expense -> Cmd Msg
addExpense user expense =
    let
        expenseJson =
            Json.Encode.object
                [ ( "expense"
                  , Json.Encode.object
                        [ ( "amount", Json.Encode.float expense.amount )
                        ]
                  )
                ]
    in
        post (newExpenseUrl user expense.budgetId)
            |> withHeader "Content-Type" "application/json"
            |> withAuthHeader user
            |> withJsonBody expenseJson
            |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
            |> Task.toResult
            |> Task.perform UpdateAdded UpdateAdded


expensesUrl : User -> Int -> String
expensesUrl user weekNumber =
    let
        params =
            [ ( "week", toString weekNumber ) ]
    in
        Http.url (user.apiBaseUrl ++ "expenses") params



-- DECODERS


decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
    Json.at [ "expenses" ] (Json.list decodeExpenseFields)


decodeExpense : Json.Decoder Expense
decodeExpense =
    Json.at [ "expense" ] decodeExpenseFields


decodeExpenseFields : Json.Decoder Expense
decodeExpenseFields =
    Json.object7 convertDecoding
        ("id" := Json.int)
        ("budget_id" := Json.int)
        ("budget_name" := Json.string)
        ("created_by_name" := Json.string)
        ("amount" := Json.string)
        ("comment" := Json.oneOf [ Json.null "", Json.string ])
        ("created_at" := Json.string)


convertDecoding : RecordId -> RecordId -> String -> String -> String -> String -> String -> Expense
convertDecoding id budgetId budgetName createdByName amount comment createdAtString =
    let
        dateResult =
            Date.fromString createdAtString

        createdAt =
            case dateResult of
                Ok date ->
                    date

                Err error ->
                    Date.fromTime 0
    in
        Expense id budgetId budgetName createdByName (toFloatPoh amount) comment createdAt
