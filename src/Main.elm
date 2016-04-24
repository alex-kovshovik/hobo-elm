module Main where

import Html exposing (..)
import Html.Attributes exposing(..)

import StartApp as StartApp
import Signal exposing (Address)
import Effects exposing (Effects, Never)
import Task

import Components.Expenses as Expenses exposing (Expense, getExpenses)
import Components.Login as Login

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
    user = Maybe.withDefault (Login.Model "" "" False) getAuth
  in
    (Model data user, Effects.map List getExpenses)


-- UPDATE
type Action
  = List Expenses.Action
  | Login Login.Action


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    List listAction ->
      let
        (listData, fx) = Expenses.update listAction model.data
      in
        ({ model | data = listData }, Effects.map List fx)

    Login loginAction ->
      let
        (userData, fx) = Login.update loginAction model.user
      in
        ({ model | user = userData }, Effects.map Login fx)


-- VIEW
view : Address Action -> Model -> Html
view address model =
  let
    currentView =
      if model.user.authenticated then
        Expenses.view (Signal.forwardTo address List) model.data
      else
        Login.view (Signal.forwardTo address Login) model.user
  in
    div [ class "container"] [
      div [ class "clear col-12 mt1" ] [
        text ("Welcome " ++ model.user.email)
      ],
      div [ class "clear col-12 mt1" ] [
        currentView
      ]
    ]

-- WIRE STUFF UP
app : StartApp.App Model
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


-- PORTS
port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port getAuth : Maybe Login.Model

port setAuth : Signal Login.Model
port setAuth =
  Signal.map .user app.model
