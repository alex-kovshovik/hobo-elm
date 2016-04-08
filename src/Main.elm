module Main where

import Html exposing (..)
import Html.Attributes exposing(..)

import StartApp as StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

import Components.Expenses as Expenses exposing (Expense)
import Components.Login as Login
import Components.BudgetButton as BudgetButton

-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: Login.Model
}

initialModel : (Model, Effects Action)
initialModel =
  let
    budgetButtons = [ (1, "Grocery"), (2, "Kids"), (3, "Other") ]
    buttonList = { buttons = budgetButtons, selectedBudget = "" }
    data = Expenses.Model [ ] buttonList 2 ""
    user = Login.Model True "74qGtYH8Qa-V1tVMa2uk" "Alex Kovshovik"
  in
    (Model data user, Effects.none)


-- UPDATE
type Action
  = List Expenses.Action
  | Login Login.Action


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    List listAction -> ({ model | data = fst (Expenses.update listAction model.data) }, Effects.none)
    Login loginAction -> (model, Effects.none)


-- VIEW
view : Address Action -> Model -> Html
view address model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.userName)
    ],
    div [ class "clear col-12 mt1" ] [
      Expenses.view (Signal.forwardTo address List) model.data
    ]
  ]

-- WIRE STUFF UP
app =
  StartApp.start {
      init = initialModel,
      update = update,
      view = view,
      inputs = []
    }

main : Signal Html
main =
  app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
