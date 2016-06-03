module Components.Expenses exposing(..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.App exposing(map)
import Date

import Components.BudgetButtonList as BBL

import Records exposing (User, Expense, Budget, RecordId, BudgetId)
import Messages.Expenses exposing(..)
import Services.Expenses exposing(..)

import Utils.Numbers exposing (toFloatPoh, formatAmount)
import Utils.Parsers exposing (resultToList, resultToObject)

-- MODEL
type alias Model = {
  buttons : BBL.Model,
  expenses : List Expense,
  nextExpenseId : Int,
  weekNumber: Int, -- relative number of week, 0 (zero) means current

  -- form
  amount : String
}

initialModel : Model
initialModel =
  Model BBL.initialModel [] 2 0 ""


-- UPDATE
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

    -- loading and displaying the list
    RequestList ->
      (model, getExpenses user model.weekNumber)

    UpdateList expensesResult ->
      ({ model | expenses = resultToList expensesResult}, Cmd.none)

    -- navigating between weeks
    LoadPreviousWeek ->
      let
        weekNumber = model.weekNumber - 1
      in
        ({ model | weekNumber = weekNumber }, getExpenses user weekNumber)

    LoadNextWeek ->
      let
        weekNumber = if model.weekNumber < 0 then model.weekNumber + 1 else model.weekNumber
      in
        ({ model | weekNumber = weekNumber }, getExpenses user weekNumber)


-- VIEW
expenseItem : Expense -> Html Msg
expenseItem expense =
  tr [ ] [
    td [ ] [
      span [ class "date" ] [
        div [ class "date-header" ] [ text (Date.month expense.createdAt |> toString) ],
        div [ class "date-day" ] [ text (Date.day expense.createdAt |> toString) ]
      ]
    ],
    td [ ] [
      a [ href "#" ] [ text expense.budgetName ]
    ],
    td [ ] [ text expense.createdByName ],
    td [ class "text-right" ] [ text (formatAmount expense.amount) ]
  ]

viewExpenseList : List Expense -> String -> Html Msg
viewExpenseList filteredExpenses totalString =
  div [ class "clear col-12 push-2-tablet push-3-desktop push-3-hd col-8-tablet col-6-desktop col-5-hd" ] [
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
  ]


viewExpenseForm : Model -> Html Msg
viewExpenseForm model =
  div [ class "clear" ] [
    div [ class "field-group" ] [
      div [ class "col-8" ] [
        input [ class "field",
                type' "number",
                id "amount",
                name "amount",
                value model.amount,
                placeholder "Amount",
                autocomplete False,
                onInput AmountInput ] [ ]
      ],
      div [ class "col-4" ] [
        button [ class "button week-button", onClick RequestAdd, disabled (model.buttons.currentBudgetId == Nothing || model.amount == "") ] [ text "Add" ]
      ]
    ]
  ]

viewButtonlist : User -> List Expense -> Model -> Html Msg
viewButtonlist user expenses model =
  map BudgetList (BBL.view user model.weekNumber expenses model.buttons)


weekHeader : Model -> String -> Html Msg
weekHeader model total =
  let
    weekName = if model.weekNumber == 0 then "This week" else
               if model.weekNumber == -1 then "Last week" else
               (toString -model.weekNumber) ++ " weeks ago"

    rightDisabledClass = if model.weekNumber == 0 then " disabled" else ""
  in
    div [ class "clear" ] [
      div [ class "col-3 col-1-hd" ] [
        button [ class "button week-button", onClick LoadPreviousWeek ] [ text "<<" ]
      ],
      div [ class "col-6 col-10-hd" ] [
        div [ class "week-header" ] [ text (weekName ++ " - " ++ total)]
      ],
      div [ class "col-3 col-1-hd" ] [
        button [ class ("button week-button" ++ rightDisabledClass), onClick LoadNextWeek ] [ text ">>" ]
      ]
    ]

view : User -> Model -> Html Msg
view user model =
  let
    filter expense =
      Just expense.budgetId == model.buttons.currentBudgetId || model.buttons.currentBudgetId == Nothing
    expenses = List.filter filter model.expenses
    expensesTotal = getTotal expenses |> formatAmount

  in
    div [ ] [
      viewButtonlist user model.expenses model,
      viewExpenseForm model,

      div [ class "clear" ] [
        weekHeader model expensesTotal
      ],

      div [ class "clear" ] [
        viewExpenseList expenses expensesTotal
      ]
    ]

viewExpense : User -> Model -> Html Msg
viewExpense user model =
  div [ ] [
    text "It works!"
  ]
