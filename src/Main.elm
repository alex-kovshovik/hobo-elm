module Main exposing(..)

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.App as Html exposing(map)

import Navigation
import Hop exposing (makeUrl, makeUrlFromLocation, matchUrl, setQuery)
import Hop.Types exposing (Config, Query, Location, PathMatcher, Router)
import Hop.Matchers exposing (..)

import Http
import HttpBuilder exposing (..)
import Task
import Json.Decode as Json exposing((:=))
import Json.Encode

import Components.Expenses as Expenses
import Components.BudgetButtonList exposing (getBudgets)
import Records exposing (User, HoboAuth)
import Utils.Parsers exposing (resultToObject)

import Messages.Expenses

import Services.Expenses exposing (getExpenses)
import Ports exposing(userData)

-- ROUTES
type Route
  = Expenses
  | Expense Int
  | NotFoundRoute


matchers : List (PathMatcher Route)
matchers =
  [ match1 Expenses "",
    match2 Expense "/expenses" int
  ]


routerConfig : Config Route
routerConfig =
  { hash = True,
    basePath = "",
    matchers = matchers,
    notFound = NotFoundRoute
  }


urlParser : Navigation.Parser ( Route, Location )
urlParser =
    Navigation.makeParser (.href >> matchUrl routerConfig)


-- MESSAGES
type Msg
  = List Messages.Expenses.Msg
  | Login HoboAuth
  | UserCheckOk (Result (Error CheckData) (Response CheckData))
  | UserCheckFail (Result (Error CheckData) (Response CheckData))
  | NavigateTo String
  | SetQuery Query


-- PROGRAM
main : Program Never
main =
  Navigation.program urlParser {
      init = init,
      view = view,
      update = update,
      urlUpdate = urlUpdate,
      subscriptions = subscriptions
    }


-- MODEL
type alias Model = {
  data: Expenses.Model,
  user: User,
  location: Location,
  route: Route
}


init : (Route, Location) -> (Model, Cmd Msg)
init (route, location) =
  let
    data = Expenses.initialModel
    user = User "" "" False "" 0.5 "USD"
  in
    (Model data user location route, Cmd.none)

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
type alias CheckData = (Float, String)

urlUpdate : (Route, Location) -> Model -> (Model, Cmd Msg)
urlUpdate (route, location) model =
  ({ model | route = route, location = location }, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (Debug.log "msg" msg) of
    List listAction ->
      let
        (listData, fx) = Expenses.update model.user listAction model.data
      in
        ({ model | data = listData }, Cmd.map List fx)

    Login hoboAuth ->
      let
        oldUser = model.user
        user = { oldUser |
          apiBaseUrl = hoboAuth.apiBaseUrl,
          email = hoboAuth.email,
          token = hoboAuth.token
        }
      in
        ({ model | user = user }, checkUser user)

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

    NavigateTo path ->
      let
        cmd = makeUrl routerConfig path |> Navigation.modifyUrl
      in
        (model, cmd)

    SetQuery query ->
      let
        cmd = model.location
                |> setQuery query
                |> makeUrlFromLocation routerConfig
                |> Navigation.modifyUrl
      in
        (model, cmd)

-- VIEW
view : Model -> Html Msg
view model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      map List (Expenses.view model.user model.data)
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

-- SUBSCRIPTIONS
subscriptions : a -> Sub Msg
subscriptions model =
  userData Login
