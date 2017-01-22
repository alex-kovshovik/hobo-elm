module App.State exposing (initialState, init, update)

import Navigation exposing (Location)
import Types exposing (..)
import App.Types exposing (..)
import App.Rest exposing (checkUser)
import Expenses.Edit.Rest exposing (loadExpense)
import Expenses.List.Rest exposing (getExpenses)
import Budgets.Rest exposing (getBudgets)
import Expenses.List.State
import Expenses.Edit.State
import BudgetEditor.State
import Expenses.List.Types exposing (Expense, ExpenseId)
import Routes exposing (parseLocation, Route(..))
import Ports exposing (logout)


init : Maybe HoboAuth -> Location -> ( Model, Cmd Msg )
init auth location =
    let
        route =
            Routes.parseLocation location
    in
        initialState auth route


initialState : Maybe HoboAuth -> Route -> ( Model, Cmd Msg )
initialState auth route =
    let
        data =
            Expenses.List.State.initialState

        editData =
            Expenses.Edit.State.initialState

        defaultUser =
            User "" "" False "" 0.5 "USD"
    in
        case auth of
            Just auth ->
                let
                    user =
                        { defaultUser
                            | apiBaseUrl = auth.apiBaseUrl
                            , email = auth.email
                            , token = auth.token
                        }
                in
                    ( Model data editData user route, checkUser user )

            Nothing ->
                ( Model data editData defaultUser route, Cmd.none )


routeLoadCommands : Model -> Cmd Msg
routeLoadCommands model =
    case model.route of
        ExpensesRoute ->
            loadExpensesCommand model.user

        ExpenseRoute expenseId ->
            loadExpenseCommand model.user expenseId

        BudgetsRoute ->
            loadBudgetsCommand model.user

        NotFoundRoute ->
            Cmd.none


afterUserCheckCommands : Model -> Cmd Msg
afterUserCheckCommands model =
    if model.user.authenticated then
        Cmd.batch [ loadBudgetsCommand model.user, routeLoadCommands model ]
    else
        Cmd.none


loadExpenseCommand : User -> ExpenseId -> Cmd Msg
loadExpenseCommand user expenseId =
    loadExpense user expenseId |> Cmd.map Edit


loadExpensesCommand : User -> Cmd Msg
loadExpensesCommand user =
    getExpenses user 0 |> Cmd.map List


loadBudgetsCommand : User -> Cmd Msg
loadBudgetsCommand user =
    getBudgets user |> Cmd.map Expenses.List.Types.BudgetList |> Cmd.map List



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        List listMsg ->
            let
                ( listData, fx ) =
                    Expenses.List.State.update model.user listMsg model.data
            in
                ( { model | data = listData }, Cmd.map List fx )

        Edit expenseMsg ->
            let
                ( editData, fx ) =
                    Expenses.Edit.State.update model.user expenseMsg model.editData
            in
                ( { model | editData = editData }, Cmd.map Edit fx )

        BudgetEditor editorMsg ->
            let
                oldData =
                    model.data

                ( buttons, fx, reloadBudgets ) =
                    BudgetEditor.State.update model.user editorMsg oldData.buttons

                data =
                    { oldData | buttons = buttons }

                reloadBudgetsFx =
                    if reloadBudgets then
                        loadBudgetsCommand model.user
                    else
                        Cmd.none

                allFx =
                    Cmd.batch
                        [ Cmd.map BudgetEditor fx
                        , reloadBudgetsFx
                        ]
            in
                ( { model | data = data }, allFx )

        UserCheckOk checkData ->
            let
                oldUser =
                    model.user

                ( weekFraction, currency ) =
                    checkData

                newUser =
                    { oldUser | authenticated = True, weekFraction = weekFraction, currency = currency }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, afterUserCheckCommands newModel )

        UserCheckFail error ->
            let
                _ =
                    Debug.log "Login failed!" error
            in
                ( model, Cmd.none )

        EditBudgets ->
            ( model, Navigation.modifyUrl "#budgets" )

        Logout ->
            ( model, logout "Bye murthafuckas!" )
