module App.State exposing (initialState, init, update, urlUpdate)

import Navigation

import Types exposing (..)
import App.Types exposing (..)

import App.Rest exposing (checkUser)
import Expense.Rest exposing (loadExpense)
import Expenses.Rest exposing (getExpenses)
import Budgets.Rest exposing (getBudgets)

import Expenses.State
import Expense.State
import BudgetEditor.State
import Expenses.Types exposing (Expense, ExpenseId)
import Routes exposing (..)

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
    editData = Expense.State.initialState
    defaultUser = User "" "" False "" 0.5 "USD"
  in
    case auth of
      Just auth ->
        let
          user = { defaultUser | apiBaseUrl = auth.apiBaseUrl,
                                 email = auth.email,
                                 token = auth.token }
        in
          (Model data editData user route, checkUser user)

      Nothing -> (Model data editData defaultUser route, Cmd.none)


routeLoadCommands : Model -> Cmd Msg
routeLoadCommands model =
  case model.route of
    ExpensesRoute ->
      loadExpensesCommand model.user

    ExpenseRoute expenseId ->
      loadExpenseCommand model.user expenseId

    BudgetsRoute ->
      loadBudgetsEffect model.user

    NotFoundRoute ->
      Cmd.none


afterUserCheckCommands : Model -> Cmd Msg
afterUserCheckCommands model =
  if model.user.authenticated
    then Cmd.batch [ loadBudgetsEffect model.user, routeLoadCommands model ]
    else Cmd.none


loadExpenseCommand : User -> ExpenseId -> Cmd Msg
loadExpenseCommand user expenseId =
  loadExpense user expenseId |> Cmd.map Edit


loadExpensesCommand : User -> Cmd Msg
loadExpensesCommand user =
  getExpenses user 0 |> Cmd.map List


loadBudgetsEffect : User -> Cmd Msg
loadBudgetsEffect user =
  getBudgets user |> Cmd.map Expenses.Types.BudgetList |> Cmd.map List


-- UPDATE
urlUpdate : Result String Route -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  let
    route = Routes.routeFromResult result
    newModel = { model | route = route }
  in
    (newModel, routeLoadCommands newModel)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    List listMsg ->
      let
        (listData, fx) = Expenses.State.update model.user listMsg model.data
      in
        ({ model | data = listData }, Cmd.map List fx)

    Edit expenseMsg ->
      let
        (editData, fx) = Expense.State.update model.user expenseMsg model.editData
      in
        ({ model | editData = editData}, Cmd.map Edit fx)

    BudgetEditor editorMsg ->
      let
        oldData = model.data
        (buttons, fx) = BudgetEditor.State.update model.user editorMsg oldData.buttons
        data = { oldData | buttons = buttons }
      in
        ({ model | data = data }, Cmd.map BudgetEditor fx)

    UserCheckOk result ->
      let
        params = Maybe.withDefault (0.0, "") (resultToObject result)
        oldUser = model.user
        newUser = { oldUser | authenticated = True, weekFraction = fst params, currency = snd params }
        newModel = { model | user = newUser }
      in
        (newModel, afterUserCheckCommands newModel)

    UserCheckFail result ->
      let
        _ = Debug.log "Login failed!" result
      in
        (model, Cmd.none)

    EditBudgets ->
      (model, Navigation.modifyUrl "#budgets")
