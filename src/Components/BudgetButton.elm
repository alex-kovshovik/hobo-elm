module Components.BudgetButton exposing(..)

import Html exposing(..)
import Html.Attributes exposing(..)
import String

import Utils.Numbers exposing (formatAmountRound)
import Services.Expenses exposing(getTotal)
import Records exposing (Budget, Expense, RecordId)

-- VIEW
buttonClass : Maybe RecordId -> Budget -> Attribute a
buttonClass currentBudgetId budget =
  let
    baseClasses = [ "bb" ]
    classes = if currentBudgetId == Just budget.id then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)

shitOrOkClass : Float -> Float -> String -> Attribute a
shitOrOkClass budgetExpenses maxBudget baseClass =
  let
    baseClasses = [ baseClass ]
    classes = if budgetExpenses > maxBudget then "shit" :: baseClasses else "ok" :: baseClasses
  in
    class (String.join " " classes)

view : Maybe RecordId -> Attribute a -> Budget -> List Expense -> Html a
view currentBudgetId clicker budget allExpenses =
  let
    expenses = List.filter (\e -> e.budgetId == budget.id) allExpenses
    totalExpenses = getTotal expenses

    leftPercentActual = 100.0 * totalExpenses / budget.amount
    leftPercent = if leftPercentActual > 100.0 then 100.0 else leftPercentActual

    rightPercent = 100.0 - leftPercent

    shitOrOk = shitOrOkClass totalExpenses budget.amount -- partial funtion execution
  in
    div [ buttonClass currentBudgetId budget, clicker ] [
      div [ class "bb-title" ] [ text budget.name ],
      div [ class "bb-prog-container" ] [
        div [ shitOrOk "bb-prog-text" ] [
          b [ ] [ text (formatAmountRound totalExpenses) ],
          text (" / " ++ (formatAmountRound budget.amount))
        ],
        div [ class "bb-prog-shitline", style [("width", "80%")] ] [ ],
        div [ shitOrOk "bb-prog-left",  style [("width", (leftPercent |> toString) ++ "%")] ] [ ],
        div [ shitOrOk "bb-prog-right", style [("width", (rightPercent |> toString) ++ "%")] ] [ ]
      ]
    ]
