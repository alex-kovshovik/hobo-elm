module BudgetEditor.Rest exposing (saveBudgets)

import HttpBuilder exposing (..)
import Json.Encode
import Task

import Types exposing (..)
import Budgets.Types exposing (Budget)
import Budgets.Rest exposing (decodeBudgets)
import BudgetEditor.Types exposing (..)

import Urls exposing (budgetsUrl)

saveBudgets : User -> List Budget -> Cmd Msg
saveBudgets user budgets =
  post (budgetsUrl user)
    |> withHeader "Content-Type" "application/json"
    |> withJsonBody (encodeBudgets budgets)
    |> send (jsonReader decodeBudgets) (jsonReader decodeBudgets)
    |> Task.toResult
    |> Task.perform SaveOk SaveOk


encodeBudgets : List Budget -> Json.Encode.Value
encodeBudgets budgets =
  let
    encodedBudgets = List.map encodeBudget budgets
  in
    Json.Encode.object [
      ("budgets", Json.Encode.list encodedBudgets)
    ]


encodeBudget : Budget -> Json.Encode.Value
encodeBudget budget =
  Json.Encode.object [
    ("id", Json.Encode.int budget.id),
    ("name", Json.Encode.string budget.name),
    ("amount", Json.Encode.float budget.amount)
  ]
