module Expenses.View exposing(root)

import Html exposing (..)
import Html.App exposing (map)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Date
import String

import Types exposing (..)
import Expenses.Types exposing (..)
import Budgets.View as Budgets

import Utils.Expenses exposing (getTotal)
import Utils.Numbers exposing (formatAmount)


root : User -> Model -> Html Msg
root user model =
  let
    filter expense =
      Just expense.budgetId == model.buttons.currentBudgetId || model.buttons.currentBudgetId == Nothing
    expenses = List.filter filter model.expenses
    expensesTotal = getTotal expenses |> formatAmount

  in
    div [ ] [
      viewExpenseForm model,
      viewBudgets user model.expenses model,
      weekHeader model expensesTotal,
      viewExpenseList expenses expensesTotal
    ]


expenseItemLinkText : Expense -> String
expenseItemLinkText expense =
  let
    title = expense.budgetName ++
      if String.length expense.comment > 0 then " ***" else ""
  in
    title


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
      a [ onClick (Show expense) ] [ text (expenseItemLinkText expense) ]
    ],
    td [ ] [ text expense.createdByName ],
    td [ class "text-right" ] [ text (formatAmount expense.amount) ]
  ]


viewExpenseList : List Expense -> String -> Html Msg
viewExpenseList filteredExpenses totalString =
  div [ class "clear col-12 mt1" ] [
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
  div [ class "clear field-group" ] [
    div [ class "col-12" ] [
      input [ class "field",
              type' "number",
              id "amount",
              name "amount",
              value model.amount,
              placeholder "Amount",
              autocomplete False,
              onInput AmountInput ] [ ]
    ]
  ]


viewBudgets : User -> List Expense -> Model -> Html Msg
viewBudgets user expenses model =
  map BudgetList (Budgets.root user model.weekNumber expenses model.buttons)


weekHeader : Model -> String -> Html Msg
weekHeader model total =
  let
    weekName = if model.weekNumber == 0 then "This week" else
               if model.weekNumber == -1 then "Last week" else
               (toString -model.weekNumber) ++ " weeks ago"

    rightDisabledClass = if model.weekNumber == 0 then " disabled" else ""
  in
    div [ class "clear mt2" ] [
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
