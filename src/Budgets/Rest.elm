module Budgets.Rest exposing (getBudgets, budgetsDecoder)

import Task
import Http
import Json.Decode as Json exposing (field)
import HttpBuilder exposing (..)
import Utils.Numbers exposing (toFloatPoh)
import Types exposing (..)
import Budgets.Types exposing (..)
import Urls exposing (..)


getBudgets : User -> Cmd Msg
getBudgets user =
    get (budgetsUrl user)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> withExpect (Http.expectJson budgetsDecoder)
        |> send handleGetBudgets


handleGetBudgets : Result Http.Error (List Budget) -> Msg
handleGetBudgets result =
    case result of
        Ok budgets ->
            LoadListOk budgets

        Err error ->
            LoadListFail error


budgetsDecoder : Json.Decoder (List Budget)
budgetsDecoder =
    Json.at [ "budgets" ] (Json.list budgetDecoder)


budgetDecoder : Json.Decoder Budget
budgetDecoder =
    Json.map3 convertDecoding
        (field "id" Json.int)
        (field "name" Json.string)
        (field "amount" Json.string)


convertDecoding : RecordId -> String -> String -> Budget
convertDecoding id name amount =
    Budget id name (toFloatPoh amount)
