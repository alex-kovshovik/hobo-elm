module Components.Expenses exposing(..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.App exposing(map)
import Task
import Http
import HttpBuilder exposing (..)
import Json.Decode as Json exposing((:=))
import Json.Encode
import Date

import Records exposing (Expense, Budget, RecordId)
import Components.BudgetButtonList as BBL
import Components.Login exposing (User)
import Components.Amount as Amount

import Utils.Numbers exposing (toFloatPoh, formatAmount)
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
type Msg
  = AmountInput String
  | BudgetList BBL.Msg
  | AmountView RecordId Amount.Msg

  -- adding/removing expenses
  | RequestAdd
  | RequestRemove Expense
  | UpdateAdded (Result (Error Expense) (Response Expense))
  | UpdateRemoved (Result (Error Expense) (Response Expense))
  | CancelDelete String

  -- loading and displaying the list
  | RequestList
  | UpdateList (Result Http.Error (List Expense))

update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    AmountInput amount ->
      ({ model | amount = amount }, Cmd.none)

    BudgetList bblAction ->
      let
        (buttonData, fx) = BBL.update user bblAction model.buttons
      in
        ({ model | buttons = buttonData }, Cmd.map BudgetList fx)

    AmountView expenseId msg ->
      let
        updateFunc expenseId expense =
          if expenseId == expense.id then Amount.update msg expense else expense

        expenses = List.map (updateFunc expenseId) model.expenses

        fx = if msg == Amount.Delete then deleteExpense user expenseId else Cmd.none
      in
        ({ model | expenses = expenses }, fx)

    -- adding/removing expenses
    RequestAdd ->
      let
        budgetId = Maybe.withDefault -1 model.buttons.currentBudgetId
        newExpense = Expense 0 budgetId "" "" (toFloatPoh model.amount) "" (Date.fromTime 0) False
      in
        ({ model | amount = "" }, addExpense user newExpense)

    RequestRemove expense ->
      let
        newExpenses = List.filter (\ex -> ex.id /= expense.id) model.expenses
      in
        ({ model | expenses = newExpenses}, Cmd.none)

    UpdateAdded expenseResult ->
      let
        newExpense = resultToObject expenseResult
        newExpenses = case newExpense of
          Just expense -> expense :: model.expenses
          Nothing -> model.expenses
      in
        ({ model | expenses = newExpenses}, Cmd.none)

    UpdateRemoved expenseResult ->
      let
        deletedExpense = resultToObject expenseResult

        newExpenses = case deletedExpense of
          Just expense -> List.filter (\e -> e.id /= expense.id) model.expenses
          Nothing -> model.expenses
      in
        ({ model | expenses = newExpenses }, Cmd.none)

    CancelDelete target ->
      let
        newExpenses = List.map (\e -> { e | clicked = False }) model.expenses
      in
        ({ model | expenses = newExpenses}, Cmd.none)

    -- loading and displaying the list
    RequestList ->
      (model, getExpenses user)

    UpdateList expensesResult ->
      ({ model | expenses = resultToList expensesResult}, Cmd.none)


-- VIEW
expenseItem : Expense -> Html Msg
expenseItem expense =
  let
    amountView = map (AmountView expense.id) (Amount.view expense)
  in
    tr [ ] [
      td [ ] [
        span [ class "date" ] [
          div [ class "date-header" ] [ text (Date.month expense.createdAt |> toString) ],
          div [ class "date-day" ] [ text (Date.day expense.createdAt |> toString) ]
        ]
      ],
      td [ ] [ text expense.budgetName ],
      td [ ] [ text expense.createdByName ],
      td [ class "text-right" ] [ amountView ]
    ]

viewExpenseList : List Expense -> String -> Html Msg
viewExpenseList filteredExpenses totalString =
  table [ ] [
    tbody [ ] (List.map expenseItem filteredExpenses),
    tfoot [ ] [
      tr [ ] [
        th [ ] [ text "" ],
        th [ ] [ text "" ],
        th [ ] [ text "Total:" ],
        th [ class "text-right" ] [ text totalString ]
      ]
    ]
  ]


viewExpenseForm : Model -> Html Msg
viewExpenseForm model =
  div [ class "field-group clear row" ] [
    div [ class "col-9" ] [
      input [ class "field",
              type' "number",
              id "amount",
              name "amount",
              value model.amount,
              placeholder "Amount",
              autocomplete False,
              onInput AmountInput ] [ ]
    ],
    div [ class "col-2" ] [
      button [ class "button", onClick RequestAdd, disabled (model.buttons.currentBudgetId == Nothing || model.amount == "") ] [ text "Add" ]
    ]
  ]

viewButtonlist : Model -> Html Msg
viewButtonlist model =
  map BudgetList (BBL.view model.buttons)

view : Model -> Html Msg
view model =
  let
    filter expense =
      Just expense.budgetId == model.buttons.currentBudgetId || model.buttons.currentBudgetId == Nothing
    expenses = List.filter filter model.expenses
    total = List.foldl (\ex sum -> sum + ex.amount) 0.0 expenses
    totalString = formatAmount total
  in
    div [ onClick (CancelDelete "delete") ] [
      div [ class "col-12" ] [
        viewButtonlist model,
        viewExpenseForm model
      ],

      div [ class "col-12 push-2-tablet push-3-desktop push-3-hd col-8-tablet col-6-desktop col-5-hd" ] [
        h3 [ class "text-center" ] [ text ("This week " ++ "(" ++ totalString ++ ")")],
        viewExpenseList expenses totalString
      ]
    ]


-- EFFECTS
getExpenses : User -> Cmd Msg
getExpenses user =
  Http.get decodeExpenses (expensesUrl user)
    |> Task.toResult
    |> Task.perform UpdateList UpdateList


addExpense : User -> Expense -> Cmd Msg
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
      |> Task.perform UpdateAdded UpdateAdded


deleteExpense : User -> RecordId -> Cmd Msg
deleteExpense user expenseId =
  delete (deleteExpenseUrl user expenseId)
    |> send (jsonReader decodeExpense) (jsonReader decodeExpense)
    |> Task.toResult
    |> Task.perform UpdateRemoved UpdateRemoved


expensesUrl : User -> String
expensesUrl user =
  Http.url (user.apiBaseUrl ++ "expenses") (authParams user)


expenseUrl : User -> BudgetId -> String
expenseUrl user budgetId =
  let
    baseUrl = user.apiBaseUrl ++ "budgets/" ++ (toString budgetId) ++ "/expenses"
  in
    Http.url baseUrl (authParams user)

deleteExpenseUrl : User -> RecordId -> String
deleteExpenseUrl user expenseId =
  let
    baseUrl = user.apiBaseUrl ++ "expenses/" ++ (toString expenseId)
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
  Json.object6 convertDecoding
    ( "id"              := Json.int )
    ( "budget_id"       := Json.int )
    ( "budget_name"     := Json.string )
    ( "created_by_name" := Json.string )
    ( "amount"          := Json.string )
    ( "created_at"      := Json.string )


convertDecoding : RecordId -> RecordId -> String -> String -> String -> String -> Expense
convertDecoding id budgetId budgetName createdByName amount createdAtString  =
  let
    dateResult = Date.fromString createdAtString
    createdAt = case dateResult of
                  Ok date -> date
                  Err error -> Date.fromTime 0
  in
    Expense id budgetId budgetName createdByName (toFloatPoh amount) "" createdAt False
