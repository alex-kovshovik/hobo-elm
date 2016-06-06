module App.State exposing (initialState, init, update, urlUpdate)

import Types exposing (..)
import App.Types exposing (..)

import App.Rest exposing (checkUser)
import Expenses.Rest exposing (getExpenses)
import Budgets.Rest exposing (getBudgets)

import Expenses.State
import Expenses.Types
import Routes exposing (Route)

import Utils.Parsers exposing (resultToObject)


init : Maybe HoboAuth -> Result String Route -> (Model, Cmd Msg)
init auth result =
  let
    currentRoute = Routes.routeFromResult result
  in
    initialState auth currentRoute


initialState : Maybe HoboAuth -> Route -> (Model, Cmd Msg)
initialState auth route =
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
          (Model data user route, checkUser user)

      Nothing -> (Model data defaultUser route, Cmd.none)


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
urlUpdate : Result String Route -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  let
    currentRoute = Routes.routeFromResult result
  in
    ({ model | route = currentRoute }, Cmd.none)


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
