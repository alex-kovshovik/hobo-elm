module Budgets.Button.View exposing(root)

import Html exposing(..)
import Html.Attributes exposing(..)
import String

import Types exposing (..)
import Budgets.Types exposing (..)
import Expenses.Types exposing (Expense)

import Utils.Numbers exposing (formatAmountRound)
import Utils.Expenses exposing (getTotal)

root : User -> Int -> Maybe RecordId -> Attribute a -> Budget -> List Expense -> Html a
root user weekNumber currentBudgetId clicker budget allExpenses =
  let
    expenses = List.filter (\e -> e.budgetId == budget.id) allExpenses
    totalExpenses = getTotal expenses

    spentFraction = totalExpenses / budget.amount
    remainFraction = 1.0 - spentFraction
    shitlineFraction = if weekNumber == 0 then user.weekFraction else 1.0
    progTextRight = if shitlineFraction < 0.5 then " right" else ""

    shitOrOk = shitOrOkClass spentFraction -- partial funtion execution
  in
    div [ buttonClass currentBudgetId budget, clicker ] [
      div [ class "bb-title" ] [ text budget.name ],
      div [ class "bb-prog-container" ] [
        div [ shitOrOk ("bb-prog-text" ++ progTextRight) ] [
          b [ ] [ text (formatAmountRound totalExpenses) ],
          text (" / " ++ (formatAmountRound budget.amount))
        ],
        div [ class "bb-prog-shitline", style [("width", (shitlineFraction |> toPercentString))] ] [ ],
        div [ shitOrOk "bb-prog-left",  style [("width", (spentFraction |> toPercentString))] ] [ ],
        div [ shitOrOk "bb-prog-right", style [("width", (remainFraction |> toPercentString))] ] [ ]
      ]
    ]


buttonClass : Maybe RecordId -> Budget -> Attribute a
buttonClass currentBudgetId budget =
  let
    baseClasses = [ "bb" ]
    classes = if currentBudgetId == Just budget.id then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)


shitOrOkClass : Float -> String -> Attribute a
shitOrOkClass spentFraction baseClass =
  let
    baseClasses = [ baseClass ]
    classes = if spentFraction > 1.0 then "shit" :: baseClasses else "ok" :: baseClasses
  in
    class (String.join " " classes)


toPercentString : Float -> String
toPercentString fraction =
  let
    cappedFraction = if fraction > 1.0 then 1.0 else
                     if fraction < 0.0 then 0.0 else fraction
  in
    (100.0 * cappedFraction |> toString) ++ "%"
