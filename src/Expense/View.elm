module Expense.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

import Date.Format exposing (format)
import Utils.Numbers exposing (formatAmount)

import Types exposing (..)
import Expense.Types exposing (..)


root : User -> Model -> Html Msg
root user model =
  let
    expense = model.expense
    comment = model.comment
  in
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
                  onInput CommentInput,
                  placeholder "Shitty thing that I bought impulsively and that I didn't really need" ] [ text comment ]
        ]
      ],

      p [ ] [
        div [ class "field-group" ] [
          button [ ] [ text "Save" ],
          button [ onClick Cancel ] [ text "Cancel" ]
        ]
      ]
    ]
