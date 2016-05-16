module Components.Amount exposing(..)

import Html exposing (..)
import Html.Attributes exposing(class)
import Html.Events exposing (onWithOptions, Options)
import Json.Decode as Json

import Records exposing (Expense)

import Utils.Numbers exposing (formatAmount)

type Msg = Click | Delete

onClick : Msg -> Attribute Msg
onClick msg =
  onWithOptions "click" (Options True True) (Json.succeed msg)

update : Msg -> Expense -> Expense
update msg expense =
  case msg of
    Click ->
      { expense | clicked = not expense.clicked }

    Delete ->
      expense

view : Expense -> Html Msg
view expense =
  if expense.clicked
    then a [ onClick Delete, class "amount-delete-link" ] [ text "Delete?" ]
    else a [ onClick Click, class "amount-link" ] [ text (formatAmount expense.amount) ]
