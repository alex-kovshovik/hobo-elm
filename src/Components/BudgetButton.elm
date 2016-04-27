module Components.BudgetButton where

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import Records exposing (Budget)

-- VIEW
buttonClass : Maybe Budget -> Budget -> Attribute
buttonClass currentBudget budget =
  let
    baseClasses = [ "button", "budget-button" ]
    classes = if currentBudget == Just budget then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)


view : Maybe Budget -> Attribute -> Budget -> Html
view currentBudget clicker budget =
  button [ buttonClass currentBudget budget, clicker ] [ text budget.name ]
