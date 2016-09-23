module Expense.Rest exposing (loadExpense, updateExpense, deleteExpense)

import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing ((:=))
import Json.Encode
import Date
import Urls exposing (..)
import Types exposing (..)
import Expenses.Types exposing (Expense, ExpenseId)
import Expense.Types exposing (..)
import Utils.Numbers exposing (toFloatPoh, formatAmount)


loadExpense : User -> ExpenseId -> Cmd Msg
loadExpense user expenseId =
    get (expenseUrl user expenseId)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
        |> Task.toResult
        |> Task.perform LoadFail LoadOk


updateExpense : User -> Expense -> Cmd Msg
updateExpense user expense =
    let
        expenseJson =
            Json.Encode.object
                [ ( "expense"
                  , Json.Encode.object
                        [ ( "amount", Json.Encode.float expense.amount )
                        , ( "comment", Json.Encode.string expense.comment )
                        ]
                  )
                ]
    in
        patch (editExpenseUrl user expense.budgetId expense.id)
            |> withHeader "Content-Type" "application/json"
            |> withAuthHeader user
            |> withJsonBody expenseJson
            |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
            |> Task.toResult
            |> Task.perform UpdateFail UpdateOk


deleteExpense : User -> ExpenseId -> Cmd Msg
deleteExpense user expenseId =
    delete (deleteExpenseUrl user expenseId)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
        |> Task.toResult
        |> Task.perform DeleteOk DeleteOk



-- DECODERS


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
