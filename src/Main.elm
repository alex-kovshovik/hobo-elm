module Main exposing(..)

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.App as Html exposing(map)

import Http
import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing((:=))
import Json.Encode

import Types exposing (..)
import Expenses.Types
import Expenses.State
import Expenses.View

import Budgets.Rest exposing (getBudgets)
import Expenses.Rest exposing (getExpenses)

import Utils.Parsers exposing (resultToObject)

import Messages.Main exposing(..)


-- PROGRAM
main : Program (Maybe HoboAuth)
main =
  Html.programWithFlags {
    init = init,
    view = view,
    update = update,
    subscriptions = \_ -> Sub.none
  }


-- MODEL
type alias Model = {
  data: Expenses.Types.Model,
  user: User
}


init : Maybe HoboAuth -> (Model, Cmd Msg)
init auth =
  let
    data = Expenses.State.initialState
    defaultUser = User "" "" False "" 0.5 "USD"
  in
    case auth of
      Just auth ->
        let
          user = { defaultUser | apiBaseUrl = auth.apiBaseUrl,
                                 email = auth.email,
                                 token = auth.token }
        in
          (Model data user, checkUser user)

      Nothing -> (Model data defaultUser, Cmd.none)


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
  getBudgets user |> Cmd.map Expenses.Types.BudgetList |> Cmd.map List


-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    List listAction ->
      let
        (listData, fx) = Expenses.State.update model.user listAction model.data
      in
        ({ model | data = listData }, Cmd.map List fx)

    UserCheckOk result ->
      let
        params = Maybe.withDefault (0.0, "") (resultToObject result)
        oldUser = model.user
        newUser = { oldUser | authenticated = True, weekFraction = fst params, currency = snd params }
      in
        ({ model | user = newUser }, initialLoadEffects newUser)

    UserCheckFail result ->
      let
        _ = Debug.log "Login failed!" result
      in
        (model, Cmd.none)


-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      map List (Expenses.View.root model.user model.data)
    ]
  ]

checkUser : User -> Cmd Msg
checkUser user =
  let
    userJson = Json.Encode.object [
      ("email", Json.Encode.string user.email),
      ("token", Json.Encode.string user.token)
    ]
  in
    post (authCheckUrl user)
      |> withHeader "Content-Type" "application/json"
      |> withJsonBody userJson
      |> send (jsonReader decodeUser) (jsonReader decodeUser)
      |> Task.toResult
      |> Task.perform UserCheckFail UserCheckOk


authCheckUrl : User -> String
authCheckUrl user =
  Http.url (user.apiBaseUrl ++ "auth/check") []


decodeUser : Json.Decoder CheckData
decodeUser =
  Json.at ["user"] decodeUserFields

decodeUserFields : Json.Decoder CheckData
decodeUserFields =
  Json.object2 (,)
    ( "week_fraction"   := Json.float )
    ( "currency"        := Json.string )
