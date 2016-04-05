module Components.BudgetButton where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import String

-- VIEW
buttonClass : String -> String -> Attribute
buttonClass selectedBudget model =
  let
    baseClasses = [ "button", "budget-button" ]
    classes = if selectedBudget == model then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)

view selectedBudget clicker model =
  button [ buttonClass selectedBudget model, clicker ] [ text model ]
