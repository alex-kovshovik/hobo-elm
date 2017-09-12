module Expenses.List.Rest exposing (getExpenses, getNewExpenseCmd)

import Budgets.Types exposing (BudgetId)
import Date
import Expenses.List.Types exposing (..)
import Http
import HttpBuilder exposing (..)
import Json.Decode as Json exposing (field)
import Json.Encode
import Task
import Types exposing (..)
import Urls exposing (..)
import Utils.Numbers exposing (formatAmount, toFloatPoh)


getExpenses : User -> Int -> Cmd Msg
getExpenses user monthNumber =
    get (expensesUrl user)
        |> withHeader "Content-Type" "application/json"
        |> withQueryParams [ ( "month", toString monthNumber ) ]
        |> withAuthHeader user
        |> withExpect (Http.expectJson decodeExpenses)
        |> send handleGetExpenses


handleGetExpenses : Result Http.Error ExpenseList -> Msg
handleGetExpenses result =
    case result of
        Ok expenses ->
            LoadListOk expenses

        Err error ->
            LoadListFail error


getNewExpenseCmd : User -> Float -> BudgetId -> Cmd Msg
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
        |> withExpect (Http.expectJson decodeExpense)
        |> send handleAddExpense


handleAddExpense : Result Http.Error Expense -> Msg
handleAddExpense result =
    case result of
        Ok expense ->
            UpdateAddedOk expense

        Err error ->
            UpdateAddedFail error


expensesUrl : User -> String
expensesUrl user =
    user.apiBaseUrl ++ "expenses"



-- DECODERS


decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
    Json.at [ "expenses" ] (Json.list decodeExpenseFields)


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
