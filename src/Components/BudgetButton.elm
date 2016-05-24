module Components.BudgetButton exposing(..)

import Html exposing(..)
import Html.Attributes exposing(..)
import String

import Utils.Numbers exposing (formatAmountRound)
import Services.Expenses exposing(getTotal)
import Records exposing (User, Budget, Expense, RecordId)

-- VIEW
buttonClass : Maybe RecordId -> Budget -> Attribute a
buttonClass currentBudgetId budget =
  let
    baseClasses = [ "bb" ]
    classes = if currentBudgetId == Just budget.id then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)

shitOrOkClass : Float -> Float -> String -> Attribute a
shitOrOkClass spentFraction shitlineFraction baseClass =
  let
    baseClasses = [ baseClass ]
    classes = if spentFraction > shitlineFraction then "shit" :: baseClasses else "ok" :: baseClasses
  in
    class (String.join " " classes)

view : User -> Int -> Maybe RecordId -> Attribute a -> Budget -> List Expense -> Html a
view user weekNumber currentBudgetId clicker budget allExpenses =
  let
    expenses = List.filter (\e -> e.budgetId == budget.id) allExpenses
    totalExpenses = getTotal expenses

    leftFraction = totalExpenses / budget.amount
    rightFraction = 1.0 - leftFraction
    shitlineFraction = if weekNumber == 0 then user.weekFraction else 1.0

    shitOrOk = shitOrOkClass leftFraction shitlineFraction -- partial funtion execution
  in
    div [ buttonClass currentBudgetId budget, clicker ] [
      div [ class "bb-title" ] [ text budget.name ],
      div [ class "bb-prog-container" ] [
        div [ shitOrOk "bb-prog-text" ] [
          b [ ] [ text (formatAmountRound totalExpenses) ],
          text (" / " ++ (formatAmountRound budget.amount))
        ],
        div [ class "bb-prog-shitline", style [("width", (shitlineFraction |> toPercentString))] ] [ ],
        div [ shitOrOk "bb-prog-left",  style [("width", (leftFraction |> toPercentString))] ] [ ],
        div [ shitOrOk "bb-prog-right", style [("width", (rightFraction |> toPercentString))] ] [ ]
      ]
    ]


toPercentString : Float -> String
toPercentString fraction =
  let
    cappedFraction = if fraction > 1.0 then 1.0 else
                     if fraction < 0.0 then 0.0 else fraction
  in
    (100.0 * cappedFraction |> toString) ++ "%"
