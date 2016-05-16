module Components.BudgetButton exposing(..)

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import Records exposing (Budget, RecordId)

-- VIEW
buttonClass : Maybe RecordId -> Budget -> Attribute a
buttonClass currentBudgetId budget =
  let
    baseClasses = [ "button", "budget-button" ]
    classes = if currentBudgetId == Just budget.id then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)


view : Maybe RecordId -> Attribute a -> Budget -> Html a
view currentBudgetId clicker budget =
  button [ buttonClass currentBudgetId budget, clicker ] [ text budget.name ]
