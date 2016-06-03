module Budgets.Rest exposing (getBudgets)

import Task
import Http
import Json.Decode as Json exposing((:=))
import Utils.Numbers exposing (toFloatPoh)

import Types exposing (..)
import Budgets.Types exposing (..)


getBudgets : User -> Cmd Msg
getBudgets user =
  Http.get decodeBudgets (budgetsUrl user)
    |> Task.toResult
    |> Task.perform DisplayFail DisplayLoaded


budgetsUrl : User -> String
budgetsUrl user =
  Http.url (user.apiBaseUrl ++ "budgets")
    [ ("user_token", user.token),
      ("user_email", user.email) ]


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
