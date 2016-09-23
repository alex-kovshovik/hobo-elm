module Budgets.Rest exposing (getBudgets, decodeBudgets)

import Task
import HttpBuilder exposing (..)
import Json.Decode as Json exposing ((:=))
import Utils.Numbers exposing (toFloatPoh)
import Types exposing (..)
import Budgets.Types exposing (..)
import Urls exposing (..)


getBudgets : User -> Cmd Msg
getBudgets user =
    get (budgetsUrl user)
        |> withHeader "Content-Type" "application/json"
        |> withAuthHeader user
        |> send (jsonReader decodeBudgets) (jsonReader decodeBudgets)
        |> Task.toResult
        |> Task.perform DisplayLoaded DisplayLoaded


decodeBudgets : Json.Decoder (List Budget)
decodeBudgets =
    Json.at [ "budgets" ] (Json.list decodeBudget)


decodeBudget : Json.Decoder Budget
decodeBudget =
    Json.object3 convertDecoding
        ("id" := Json.int)
        ("name" := Json.string)
        ("amount" := Json.string)


convertDecoding : RecordId -> String -> String -> Budget
convertDecoding id name amount =
    Budget id name (toFloatPoh amount)
