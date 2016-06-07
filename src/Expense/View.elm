module Expense.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)

import Date.Format exposing (format)
import Utils.Numbers exposing (formatAmount)

import Types exposing (..)
import Expense.Types exposing (..)
import Expenses.Types exposing (ExpenseId, Expense, ExpenseList)


root : User -> ExpenseList -> ExpenseId -> Html Msg
root user expenses expenseId =
  let
    expense = List.filter (\e -> e.id == expenseId) expenses |> List.head
  in
    case expense of
      Just expense -> showExpense expense
      Nothing ->
        div [ ] [
          text "Woah! Expense not found by ID!"
        ]


showExpense : Expense -> Html Msg
showExpense expense =
  div [ class "col-12" ] [
    h2 [ ] [ text ("Expense ID " ++ (toString expense.id))],

    p [ ] [
      label [ ] [ text "Date: " ],
      text (expense.createdAt |> format "%B, %d")
    ],

    p [ ] [
      label [ ] [ text "Budget: " ],
      text expense.budgetName
    ],

    p [ ] [
      label [ ] [ text "Amount: " ],
      text (expense.amount |> formatAmount)
    ],

    p [ ] [
      label [ ] [ text "Comment: " ],
      div [ class "field-group" ] [
        textarea [ class "field",
                id "expense-comment",
                name "expense-comment",
                value expense.comment,
                placeholder "Shitty thing that I bought impulsively and that I didn't really need" ] [ ]
      ]
    ],

    p [ ] [
      div [ class "field-group" ] [
        button [ ] [ text "Save" ],
        button [ ] [ text "Cancel" ]
      ]
    ]
  ]
