module Components.Expenses where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Numeral
import Task
import Effects exposing (Effects)
import Http
import Json.Decode as Json exposing((:=))

import Records exposing (Expense, Budget, RecordId)
import Components.BudgetButtonList as BBL
import Components.Login exposing (User)
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

initialModel : Model
initialModel =
  Model BBL.initialModel [] 2 ""

-- UPDATE
type Action
  = Add
  | AmountInput String
  | BudgetList BBL.Action
  | Request
  | DisplayLoaded (Result Http.Error (List Expense))

update : User -> Action -> Model -> (Model, Effects Action)
update user action model =
  case action of
    Add ->
      let
        budgetId = Maybe.withDefault -1 model.buttons.currentBudgetId
        newExpense = Expense model.nextExpenseId budgetId "this is going to be replaced with AJAX load" (toFloatPoh model.amount) ""
      in
        ({ model |
            expenses = newExpense :: model.expenses,
            nextExpenseId = model.nextExpenseId + 1,
            amount = ""
        }, Effects.none)

    AmountInput amount ->
      ({ model | amount = amount }, Effects.none)

    BudgetList bblAction ->
      let
        (buttonData, fx) = BBL.update user bblAction model.buttons
      in
        ({ model | buttons = buttonData }, Effects.map BudgetList fx)

    Request ->
      (model, getExpenses user)

    DisplayLoaded expensesResult ->
      ({ model | expenses = resultToList expensesResult}, Effects.none)


-- VIEW
expenseText : Expense -> String
expenseText expense =
  Numeral.format "$0,0.00" expense.amount


expenseItem : Expense -> Html
expenseItem expense =
  tr [ ] [
    td [ ] [ text (expense.budgetName) ],
    td [ ] [ text (expenseText expense) ]
  ]

viewExpenseList : Model -> Html
viewExpenseList model =
  let
    filter expense =
      Just expense.budgetId == model.buttons.currentBudgetId || model.buttons.currentBudgetId == Nothing
    expenses = List.filter filter model.expenses
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
      button [ class "button", onClick address Add, disabled (model.buttons.currentBudgetId == Nothing || model.amount == "") ] [ text "Add" ]
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
    h3 [ ] [ text "This week" ],
    viewExpenseList model
  ]


-- EFFECTS
getExpenses : User -> Effects Action
getExpenses user =
  Http.get decodeExpenses (expensesUrl user)
    |> Task.toResult
    |> Task.map DisplayLoaded
    |> Effects.task


expensesUrl : User -> String
expensesUrl user =
  Http.url "http://localhost:3000/expenses"
    [ ("user_token", user.token),
      ("user_email", user.email) ]


decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
  Json.at ["expenses"] (Json.list decodeExpense)


decodeExpense : Json.Decoder Expense
decodeExpense =
  Json.object4 convertDecoding
    ( "id"          := Json.int )
    ( "budget_id"   := Json.int )
    ( "budget_name" := Json.string )
    ( "amount"      := Json.string )


convertDecoding : RecordId -> RecordId -> String -> String -> Expense
convertDecoding id budgetId budgetName amount =
    Expense id budgetId budgetName (toFloatPoh amount) ""
