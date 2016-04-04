module Components.Expenses (Action, Expense, Model, view, update) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)

import Components.BudgetButtonList as BBL
import Utils.Numbers exposing (onInput, toFloatPoh)

-- MODEL
type alias Expense = {
  id : Int,
  budget: String,
  amount : Float
}

type alias Model = {
  expenses : List Expense,
  budgets : BBL.Model,
  nextId : Int,

  -- form
  amount : String
}

-- UPDATE
type Action
  = Add
  | AmountInput String
  | BudgetList BBL.Action

update : Action -> Model -> Model
update action model =
  case action of
    Add ->
      let
        newExpense = Expense model.nextId model.budgets.selectedBudget (toFloatPoh model.amount)
      in
        { model |
            expenses = newExpense :: model.expenses,
            nextId = model.nextId + 1,
            amount = ""
        }

    AmountInput amount -> { model | amount = amount }

    BudgetList bblAction -> { model | budgets = BBL.update bblAction model.budgets }


-- VIEW
expenseText expense =
  toString expense.amount


expenseItem : Expense -> Html
expenseItem expense =
  li [ ] [ text (expenseText expense), text (" " ++ expense.budget) ]


viewExpenseList model =
  ul [ ] (List.map expenseItem model.expenses)


viewExpenseForm : Address Action -> Model -> Html
viewExpenseForm address model =
  div [ class "field-group clear row" ] [
    div [ class "col-9" ] [
      input [ class "field",
              type' "number",
              id "amount",
              name "amount",
              value model.amount,
              placeholder "Amount",
              onInput address AmountInput ] [ ]
    ],
    div [ class "col-3" ] [
      button [ class "button", onClick address Add ] [ text "Add" ]
    ]
  ]

viewButtonlist : Address Action -> Model -> Html
viewButtonlist address model =
  BBL.view (Signal.forwardTo address BudgetList) model.budgets

view : Address Action -> Model -> Html
view address model =
  div [ ] [
    viewButtonlist address model,
    viewExpenseForm address model,
    h3 [ ] [ text "April 2016" ],
    viewExpenseList model
  ]
