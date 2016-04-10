module Components.Expenses (Action, Expense, Model, view, update, getExpenses) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Numeral
import Task
import Effects exposing(Effects)
import Http
import Json.Decode as Json exposing((:=))
import Debug

import Components.BudgetButtonList as BBL
import Utils.Numbers exposing (onInput, toFloatPoh)

-- MODEL
type alias Expense = {
  id : Int,
  budget: String,
  amount : Float
}

type alias ExpenseList = List Expense

type alias Model = {
  expenses : ExpenseList,
  budgets : BBL.Model,
  nextId : Int,

  -- form
  amount : String
}

-- UPDATE
type Action
  = Add
  | AmountInput String
  | BudgetList BBL.Action
  | Request
  | DisplayLoaded (Result Http.Error ExpenseList)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Add ->
      let
        newExpense = Expense model.nextId model.budgets.selectedBudget (toFloatPoh model.amount)
      in
        ({ model |
            expenses = newExpense :: model.expenses,
            nextId = model.nextId + 1,
            amount = ""
        }, Effects.none)

    AmountInput amount ->
      ({ model | amount = amount }, Effects.none)

    BudgetList bblAction ->
      ({ model | budgets = BBL.update bblAction model.budgets }, Effects.none)

    Request ->
      (model, getExpenses)

    DisplayLoaded expensesResult ->
      ({ model | expenses = parseExpenses expensesResult}, Effects.none)


parseExpenses : Result Http.Error ExpenseList -> ExpenseList
parseExpenses expenses =
  case expenses of
    Ok list -> list
    Err error ->
      let
        errorMessage = Debug.log "Expense loading/decoding error" error
      in
        []

-- VIEW
expenseText expense =
  Numeral.format "$0,0.00" expense.amount


expenseItem : Expense -> Html
expenseItem expense =
  li [ ] [ text (expenseText expense), text (" " ++ expense.budget) ]


viewExpenseList model =
  ul [ ] (List.map expenseItem model.expenses)


viewExpenseForm : Address Action -> Model -> Html
viewExpenseForm address model =
  div [ class "field-group clear row" ] [
    div [ class "col-9" ] [
      input [ class "field",
              type' "number",
              id "amount",
              name "amount",
              value model.amount,
              placeholder "Amount",
              onInput address AmountInput ] [ ]
    ],
    div [ class "col-2" ] [
      button [ class "button", onClick address Add ] [ text "Add" ]
    ]
  ]

viewButtonlist : Address Action -> Model -> Html
viewButtonlist address model =
  BBL.view (Signal.forwardTo address BudgetList) model.budgets

view : Address Action -> Model -> Html
view address model =
  div [ ] [
    viewButtonlist address model,
    viewExpenseForm address model,
    h3 [ ] [ text "April 2016" ],
    viewExpenseList model,
    button [ onClick address Request ] [ text "Load Expenses!" ]
  ]


-- Effects
getExpenses : Effects Action
getExpenses =
  Http.get decodeExpenses "http://localhost:3000/expenses?user_token=74qGtYH8Qa-V1tVMa2uk&user_email=alex%40shovik.com"
    |> Task.toResult
    |> Task.map DisplayLoaded
    |> Effects.task


-- This is an attempt to send authorization in headers,
-- but I decided to give up on it until later.
-- createRequest url =
--   Http.send Http.defaultSettings {
--     verb = "GET",
--     headers = [("X-User-Token", "74qGtYH8Qa-V1tVMa2uk"),
--                ("X-User-Email", "alex@shovik.com"),
--                ("Content-Type", "application/json")],
--     url = url,
--     body = Http.empty
--   }


decodeExpenses : Json.Decoder ExpenseList
decodeExpenses =
  Json.at ["expenses"] (Json.list decodeExpense)


decodeExpense : Json.Decoder Expense
decodeExpense =
  Json.object3 convertDecoding
    ( "id"     := Json.int )
    ( "budget" := Json.string )
    ( "amount" := Json.string )


-- This is only needed to convert amount encoded as String into Float,
-- But later I'll be converting budget_id into a Budget record.
convertDecoding : Int -> String -> String -> Expense
convertDecoding id budget amount =
  Expense id budget (toFloatPoh amount)
