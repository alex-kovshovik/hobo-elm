module BudgetEditor.Rest exposing (saveBudgets, deleteBudget)

import Http
import HttpBuilder exposing (..)
import Json.Encode
import Task
import Urls exposing (withAuthHeader)
import Types exposing (..)
import Budgets.Types exposing (Budget, BudgetId)
import Budgets.Rest exposing (budgetsDecoder)
import BudgetEditor.Types exposing (..)
import Urls exposing (budgetsUrl, deleteBudgetUrl)


saveBudgets : User -> List Budget -> Cmd Msg
saveBudgets user budgets =
    post (budgetsUrl user)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> withJsonBody (encodeBudgets budgets)
        |> withExpect (Http.expectJson budgetsDecoder)
        |> send handleSaveBudgets


handleSaveBudgets : Result Http.Error (List Budget) -> Msg
handleSaveBudgets result =
    case result of
        Ok budgets ->
            SaveOk budgets

        Err error ->
            SaveFail error


deleteBudget : User -> BudgetId -> Cmd Msg
deleteBudget user budgetId =
    delete (deleteBudgetUrl user budgetId)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> withExpect Http.expectString
        |> send handleDeleteBudget


handleDeleteBudget : Result Http.Error String -> Msg
handleDeleteBudget result =
    case result of
        Ok response ->
            DeleteOk response

        Err error ->
            DeleteFail error



-- Encoders and decoders


encodeBudgets : List Budget -> Json.Encode.Value
encodeBudgets budgets =
    let
        encodedBudgets =
            List.map encodeBudget budgets
    in
        Json.Encode.object
            [ ( "budgets", Json.Encode.list encodedBudgets )
            ]


encodeBudget : Budget -> Json.Encode.Value
encodeBudget budget =
    Json.Encode.object
        [ ( "id", Json.Encode.int budget.id )
        , ( "name", Json.Encode.string budget.name )
        , ( "amount", Json.Encode.float budget.amount )
        ]
