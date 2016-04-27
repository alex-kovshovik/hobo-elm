module Main where

import Html exposing (..)
import Html.Attributes exposing(..)

import StartApp as StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

import Records exposing (Budget, Expense, RecordId)
import Components.Expenses as Expenses exposing (getExpenses)
import Components.Login as Login

-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: Login.User
}

initialModel : (Model, Effects Action)
initialModel =
  let
    budgets = [ (Budget 1 "Grocery"), (Budget 2 "Kids"), (Budget 3 "Other") ]
    buttonList = { budgets = budgets, currentBudget = Nothing }
    data = Expenses.Model buttonList [] 2 ""
    user = Login.User "" "" False
  in
    (Model data user, Effects.none)

loadListEffect : Login.User -> Effects Action
loadListEffect user =
  if user.authenticated
    then Effects.map List getExpenses
    else Effects.none

-- UPDATE
type Action
  = List Expenses.Action
  | Login Login.User


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    List listAction ->
      let
        (listData, fx) = Expenses.update listAction model.data
      in
        ({ model | data = listData }, Effects.map List fx)

    Login user ->
      ({ model | user = user }, loadListEffect user)


-- VIEW
view : Address Action -> Model -> Html
view address model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear col-12 mt1" ] [
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
  Signal.map Login loginSuccess


-- PORTS
port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port loginSuccess : Signal Login.User
