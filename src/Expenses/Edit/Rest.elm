module Expenses.Edit.Rest exposing (loadExpense, updateExpense, deleteExpense)

import Http
import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing (field)
import Json.Encode
import Date
import Urls exposing (..)
import Types exposing (..)
import Expenses.List.Types exposing (Expense, ExpenseId)
import Expenses.Edit.Types exposing (..)
import Utils.Numbers exposing (toFloatPoh, formatAmount)


loadExpense : User -> ExpenseId -> Cmd Msg
loadExpense user expenseId =
    get (expenseUrl user expenseId)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> withExpect (Http.expectJson decodeExpense)
        |> send handleLoadExpense


handleLoadExpense : Result Http.Error Expense -> Msg
handleLoadExpense result =
    case result of
        Ok expense ->
            LoadOk expense

        Err error ->
            LoadFail error


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
            |> withExpect (Http.expectJson decodeExpense)
            |> send handleUpdateExpense


handleUpdateExpense : Result Http.Error Expense -> Msg
handleUpdateExpense result =
    case result of
        Ok expense ->
            UpdateOk expense

        Err error ->
            UpdateFail error


deleteExpense : User -> ExpenseId -> Cmd Msg
deleteExpense user expenseId =
    delete (deleteExpenseUrl user expenseId)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> withExpect (Http.expectJson decodeExpense)
        |> send handleDeleteExpense


handleDeleteExpense : Result Http.Error Expense -> Msg
handleDeleteExpense result =
    case result of
        Ok expense ->
            DeleteOk expense

        Err error ->
            DeleteFail error



-- DECODERS


decodeExpense : Json.Decoder Expense
decodeExpense =
    Json.at [ "expense" ] decodeExpenseFields


decodeExpenseFields : Json.Decoder Expense
decodeExpenseFields =
    Json.map7 convertDecoding
        (field "id" Json.int)
        (field "budget_id" Json.int)
        (field "budget_name" Json.string)
        (field "created_by_name" Json.string)
        (field "amount" Json.string)
        (field "comment" (Json.oneOf [ Json.null "", Json.string ]))
        (field "created_at" Json.string)


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
