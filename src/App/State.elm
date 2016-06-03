module App.State exposing (initialState, update)

import Types exposing (..)
import App.Types exposing (..)

import App.Rest exposing (checkUser)
import Expenses.Rest exposing (getExpenses)
import Budgets.Rest exposing (getBudgets)

import Expenses.State
import Expenses.Types

import Utils.Parsers exposing (resultToObject)


initialState : Maybe HoboAuth -> (Model, Cmd Msg)
initialState auth =
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
