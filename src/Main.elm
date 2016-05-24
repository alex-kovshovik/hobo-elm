module Main exposing(..)

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.App as Html exposing(map)

import Components.Expenses as Expenses
import Components.BudgetButtonList exposing (getBudgets)
import Components.Login exposing (User)

import Messages.Expenses

import Services.Expenses exposing (getExpenses)
import Ports exposing(userData)


-- PROGRAM
main : Program Never
main =
  Html.program {
      init = initialModel,
      update = update,
      view = view,
      subscriptions = subscriptions
    }


-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: User
}

initialModel : (Model, Cmd Msg)
initialModel =
  let
    data = Expenses.initialModel
    user = User "" "" False ""
  in
    (Model data user, Cmd.none)

initialLoadEffects : User -> Cmd Msg
initialLoadEffects user =
  if user.authenticated
    then Cmd.batch [ loadExpensesEffect user, loadBudgetsEffect user ]
    else Cmd.none


loadExpensesEffect : User -> Cmd Msg
loadExpensesEffect user =
  getExpenses user 0 |> Cmd.map List


loadBudgetsEffect : User -> Cmd Msg
loadBudgetsEffect user =
  getBudgets user |> Cmd.map Messages.Expenses.BudgetList |> Cmd.map List


-- UPDATE
type Msg
  = List Messages.Expenses.Msg
  | Login User


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    List listAction ->
      let
        (listData, fx) = Expenses.update model.user listAction model.data
      in
        ({ model | data = listData }, Cmd.map List fx)

    Login user ->
      ({ model | user = user }, initialLoadEffects user)


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container-full"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      map List (Expenses.view model.data)
    ]
  ]


-- SUBSCRIPTIONS
subscriptions : a -> Sub Msg
subscriptions model =
  userData Login
