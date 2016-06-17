module Budgets.Rest exposing (getBudgets, decodeBudgets)

import Task
import Http
import Json.Decode as Json exposing((:=))
import Utils.Numbers exposing (toFloatPoh)

import Types exposing (..)
import Budgets.Types exposing (..)
import Urls exposing (budgetsUrl)


getBudgets : User -> Cmd Msg
getBudgets user =
  Http.get decodeBudgets (budgetsUrl user)
    |> Task.toResult
    |> Task.perform DisplayFail DisplayLoaded


decodeBudgets : Json.Decoder (List Budget)
decodeBudgets =
  Json.at ["budgets"] (Json.list decodeBudget)


decodeBudget : Json.Decoder Budget
decodeBudget =
  Json.object3 convertDecoding
    ( "id"     := Json.int )
    ( "name"   := Json.string )
    ( "amount" := Json.string )


convertDecoding : RecordId -> String -> String -> Budget
convertDecoding id name amount =
  Budget id name (toFloatPoh amount)
