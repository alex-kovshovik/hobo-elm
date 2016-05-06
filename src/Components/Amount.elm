module Components.Amount where

import Html exposing (..)
import Html.Attributes exposing(class)
import Html.Events exposing (onClick)
import Signal exposing (Address)

import Records exposing (Expense)

import Utils.Numbers exposing (formatAmount)

type Action = Click | Delete

update : Action -> Expense -> Expense
update action expense =
  case action of
    Click ->
      { expense | clicked = not expense.clicked }

    Delete ->
      expense

view : Address Action -> Expense -> Html
view address expense =
  if expense.clicked
    then a [ onClick address Delete, class "amount-delete-link" ] [ text "Delete?" ]
    else a [ onClick address Click, class "amount-link" ] [ text (formatAmount expense.amount) ]
