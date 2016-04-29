module Components.BudgetButton where

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import Records exposing (Budget, RecordId)

-- VIEW
buttonClass : Maybe RecordId -> Budget -> Attribute
buttonClass currentBudgetId budget =
  let
    baseClasses = [ "button", "budget-button" ]
    classes = if currentBudgetId == Just budget.id then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)


view : Maybe RecordId -> Attribute -> Budget -> Html
view currentBudgetId clicker budget =
  button [ buttonClass currentBudgetId budget, clicker ] [ text budget.name ]
