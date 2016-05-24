module Components.Amount exposing(..)

import Html exposing (..)
import Html.Attributes exposing(class)
import Html.Events exposing (onWithOptions, Options)
import Json.Decode as Json

import Records exposing (User, Expense)
import Messages.Amount exposing (..)
import Messages.Expenses
import Services.Expenses exposing(deleteExpense)

import Utils.Numbers exposing (formatAmount)

onClick : Msg -> Attribute Msg
onClick msg =
  onWithOptions "click" (Options True True) (Json.succeed msg)

update : User -> Msg -> Expense -> (Expense, Cmd Messages.Expenses.Msg)
update user msg expense =
  case msg of
    Click ->
      ({ expense | clicked = not expense.clicked }, Cmd.none)

    Delete ->
      (expense, deleteExpense user expense.id)

view : Expense -> Html Msg
view expense =
  if expense.clicked
    then a [ onClick Delete, class "amount-delete-link" ] [ text "Delete?" ]
    else a [ onClick Click, class "amount-link" ] [ text (formatAmount expense.amount) ]
