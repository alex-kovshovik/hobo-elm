module Main where

import Html exposing (..)
import Html.Attributes exposing(..)

import StartApp as StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

import Components.Expenses as Expenses exposing (getExpenses)
import Components.BudgetButtonList exposing (getBudgets)
import Components.Login exposing (User)

-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: User
}

initialModel : (Model, Effects Action)
initialModel =
  let
    data = Expenses.initialModel
    user = User "" "" False ""
  in
    (Model data user, Effects.none)

initialLoadEffects : User -> Effects Action
initialLoadEffects user =
  if user.authenticated
    then Effects.batch [ loadExpensesEffect user, loadBudgetsEffect user ]
    else Effects.none


loadExpensesEffect : User -> Effects Action
loadExpensesEffect user =
  getExpenses user |> Effects.map List


loadBudgetsEffect : User -> Effects Action
loadBudgetsEffect user =
  getBudgets user |> Effects.map Expenses.BudgetList |> Effects.map List


-- UPDATE
type Action
  = List Expenses.Action
  | Login User


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    List listAction ->
      let
        (listData, fx) = Expenses.update model.user listAction model.data
      in
        ({ model | data = listData }, Effects.map List fx)

    Login user ->
      ({ model | user = user }, initialLoadEffects user)


-- VIEW
view : Address Action -> Model -> Html
view address model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      Expenses.view (Signal.forwardTo address List) model.data
    ]
  ]

-- WIRE STUFF UP
app : StartApp.App Model
app =
  StartApp.start {
      init = initialModel,
      update = update,
      view = view,
      inputs = [ loginActions ]
    }

main : Signal Html
main =
  app.html


-- SIGNALS
loginActions : Signal Action
loginActions =
  Signal.map Login userData


-- PORTS
port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port userData : Signal User
