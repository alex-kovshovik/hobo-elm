module Components.Expenses where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Numeral
import Task
import Effects exposing(Effects)
import Http
import Json.Decode as Json exposing((:=))

import Records exposing (Expense, Budget, RecordId)
import Components.BudgetButtonList as BBL
import Utils.Numbers exposing (onInput, toFloatPoh)
import Utils.Parsers exposing (resultToList)

-- MODEL
type alias Model = {
  buttons : BBL.Model,
  expenses : List Expense,
  nextExpenseId : Int,

  -- form
  amount : String
}

-- UPDATE
type Action
  = Add
  | AmountInput String
  | BudgetList BBL.Action
  | Request
  | DisplayLoaded (Result Http.Error (List Expense))

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Add ->
      let
        budget = Maybe.withDefault (Budget 0 "Undefined") model.buttons.currentBudget
        newExpense = Expense model.nextExpenseId budget (toFloatPoh model.amount) ""
      in
        ({ model |
            expenses = newExpense :: model.expenses,
            nextExpenseId = model.nextExpenseId + 1,
            amount = ""
        }, Effects.none)

    AmountInput amount ->
      ({ model | amount = amount }, Effects.none)

    BudgetList bblAction ->
      ({ model | buttons = BBL.update bblAction model.buttons }, Effects.none)

    Request ->
      (model, getExpenses)

    DisplayLoaded expensesResult ->
      ({ model | expenses = resultToList expensesResult}, Effects.none)


-- VIEW
expenseText : Expense -> String
expenseText expense =
  Numeral.format "$0,0.00" expense.amount


expenseItem : Expense -> Html
expenseItem expense =
  tr [ ] [
    td [ ] [ text (expense.budget.name) ],
    td [ ] [ text (expenseText expense) ]
  ]

viewExpenseList : Model -> Html
viewExpenseList model =
  let
    lambda expense =
      Just expense.budget == model.buttons.currentBudget || model.buttons.currentBudget == Nothing
    expenses = List.filter lambda model.expenses
  in
    table [ ] (List.map expenseItem expenses)


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
      button [ class "button", onClick address Add, disabled (model.buttons.currentBudget == Nothing || model.amount == "") ] [ text "Add" ]
    ]
  ]

viewButtonlist : Address Action -> Model -> Html
viewButtonlist address model =
  BBL.view (Signal.forwardTo address BudgetList) model.buttons

view : Address Action -> Model -> Html
view address model =
  div [ ] [
    viewButtonlist address model,
    viewExpenseForm address model,
    h3 [ ] [ text "April 2016" ],
    viewExpenseList model
  ]


-- EFFECTS
getExpenses : Effects Action
getExpenses =
  Http.get decodeExpenses "http://localhost:3000/expenses?user_token=74qGtYH8Qa-V1tVMa2uk&user_email=alex%40shovik.com"
    |> Task.toResult
    |> Task.map DisplayLoaded
    |> Effects.task


decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
  Json.at ["expenses"] (Json.list decodeExpense)


decodeExpense : Json.Decoder Expense
decodeExpense =
  Json.object4 convertDecoding
    ( "id"        := Json.int )
    ( "budget_id" := Json.int )
    ( "amount"    := Json.string )
    ( "comment"   := Json.string )


convertDecoding : RecordId -> RecordId -> String -> String -> Expense
convertDecoding id budgetId amount comment =
  let
    budget = Budget 0 "Undefined"
  in
    Expense id budget (toFloatPoh amount) comment
