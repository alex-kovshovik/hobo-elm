module Components.Expenses where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Numeral
import Task
import Effects exposing (Effects)
import Http
import Http.Extra as HttpExtra exposing (..)
import Json.Decode as Json exposing((:=))
import Json.Encode
import Date
import Date.Format exposing (format)

import Records exposing (Expense, Budget, RecordId)
import Components.BudgetButtonList as BBL
import Components.Login exposing (User)
import Utils.Numbers exposing (onInput, toFloatPoh)
import Utils.Parsers exposing (resultToList, resultToObject)

-- MODEL
type alias Model = {
  buttons : BBL.Model,
  expenses : List Expense,
  nextExpenseId : Int,

  -- form
  amount : String
}

type alias BudgetId = RecordId

initialModel : Model
initialModel =
  Model BBL.initialModel [] 2 ""

-- UPDATE
type Action
  = AmountInput String
  | BudgetList BBL.Action

  -- adding/removing expenses
  | RequestAdd
  | RequestRemove Expense
  | UpdateAdded (Result (Error Expense) (Response Expense))

  -- loading and displaying the list
  | RequestList
  | UpdateList (Result Http.Error (List Expense))

update : User -> Action -> Model -> (Model, Effects Action)
update user action model =
  case action of
    AmountInput amount ->
      ({ model | amount = amount }, Effects.none)

    BudgetList bblAction ->
      let
        (buttonData, fx) = BBL.update user bblAction model.buttons
      in
        ({ model | buttons = buttonData }, Effects.map BudgetList fx)

    -- adding/removing expenses
    RequestAdd ->
      let
        budgetId = Maybe.withDefault -1 model.buttons.currentBudgetId
        newExpense = Expense 0 budgetId "" (toFloatPoh model.amount) "" (Date.fromTime 0)
      in
        ({ model | amount = "" }, addExpense user newExpense)

    RequestRemove expense ->
      let
        newExpenses = List.filter (\ex -> ex.id /= expense.id) model.expenses
      in
        ({ model | expenses = newExpenses}, Effects.none)

    UpdateAdded expenseResult ->
      let
        newExpense = resultToObject expenseResult
        newExpenses = case newExpense of
          Just expense -> expense::model.expenses
          Nothing -> model.expenses

      in
        ({ model | expenses = newExpenses}, Effects.none)

    -- loading and displaying the list
    RequestList ->
      (model, getExpenses user)

    UpdateList expensesResult ->
      ({ model | expenses = resultToList expensesResult}, Effects.none)


-- VIEW
formatAmount : Float -> String
formatAmount amount =
  Numeral.format "$0,0.00" amount


expenseItem : Address Action -> Expense -> Html
expenseItem address expense =
  tr [ ] [
    td [ ] [ text (format "%b %d" expense.createdAt) ],
    td [ ] [ text expense.budgetName ],
    td [ class "text-right" ] [ text (formatAmount expense.amount) ],
    td [ ] [ text "X" ]
    -- td [ ] [ button [ class "delete", onClick address (RequestRemove expense) ] [ text "X" ] ]
  ]

viewExpenseList : Address Action -> Model -> Html
viewExpenseList address model =
  let
    filter expense =
      Just expense.budgetId == model.buttons.currentBudgetId || model.buttons.currentBudgetId == Nothing
    expenses = List.filter filter model.expenses
    total = List.foldl (\ex sum -> sum + ex.amount) 0.0 expenses
  in
    table [ ] [
      tbody [ ] (List.map (expenseItem address) expenses),
      tfoot [ ] [
        tr [ ] [
          th [ ] [ text "" ],
          th [ ] [ text "Total:" ],
          th [ class "text-right" ] [ text (formatAmount total) ],
          th [ ] [ text "" ]
        ]
      ]
    ]


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
              autocomplete False,
              onInput address AmountInput ] [ ]
    ],
    div [ class "col-2" ] [
      button [ class "button", onClick address RequestAdd, disabled (model.buttons.currentBudgetId == Nothing || model.amount == "") ] [ text "Add" ]
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
    h3 [ class "text-center" ] [ text "This week" ],
    viewExpenseList address model
  ]


-- EFFECTS
getExpenses : User -> Effects Action
getExpenses user =
  Http.get decodeExpenses (expensesUrl user)
    |> Task.toResult
    |> Task.map UpdateList
    |> Effects.task


addExpense : User -> Expense -> Effects Action
addExpense user expense =
  let
    expenseJson = Json.Encode.object [
      ("expense", Json.Encode.object [
        ("amount", Json.Encode.float expense.amount)
      ])
    ]
  in
    post (expenseUrl user expense.budgetId)
      |> withHeader "Content-Type" "application/json"
      |> withJsonBody expenseJson
      |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
      |> Task.toResult
      |> Task.map UpdateAdded
      |> Effects.task


-- TODO: continue implementation
-- deleteExpense : User -> Expense -> Effects Action
-- deleteExpense user expense =
--
--

expensesUrl : User -> String
expensesUrl user =
  Http.url "http://localhost:3000/expenses" (authParams user)


expenseUrl : User -> BudgetId -> String
expenseUrl user budgetId =
  let
    baseUrl = "http://localhost:3000/budgets/" ++ (toString budgetId) ++ "/expenses"
  in
    Http.url baseUrl (authParams user)


authParams : User -> List (String, String)
authParams user =
  [ ("user_token", user.token),
    ("user_email", user.email) ]


-- DECODERS
decodeExpenses : Json.Decoder (List Expense)
decodeExpenses =
  Json.at ["expenses"] (Json.list decodeExpenseFields)


decodeExpense : Json.Decoder Expense
decodeExpense =
  Json.at ["expense"] decodeExpenseFields


decodeExpenseFields : Json.Decoder Expense
decodeExpenseFields =
  Json.object5 convertDecoding
    ( "id"          := Json.int )
    ( "budget_id"   := Json.int )
    ( "budget_name" := Json.string )
    ( "amount"      := Json.string )
    ( "created_at"  := Json.string )


convertDecoding : RecordId -> RecordId -> String -> String -> String -> Expense
convertDecoding id budgetId budgetName amount createdAtString =
  let
    dateResult = Date.fromString createdAtString
    createdAt = case dateResult of
                  Ok date -> date
                  Err error -> Date.fromTime 0
  in
    Expense id budgetId budgetName (toFloatPoh amount) "" createdAt
