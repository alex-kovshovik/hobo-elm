module Expenses.List.State exposing (initialState, update)

import Budgets.State as Budgets
import Debug
import Expenses.List.Rest exposing (..)
import Expenses.List.Types exposing (..)
import Navigation
import String
import Types exposing (..)
import Utils.Numbers exposing (toFloatPoh)


initialState : Model
initialState =
    { buttons = Budgets.initialModel
    , expenses = []
    , monthNumber = 0
    , amount = ""
    }


update : User -> Msg -> Model -> ( Model, Cmd Msg )
update user msg model =
    case msg of
        AmountInput amount ->
            let
                buttons =
                    model.buttons

                newButtons =
                    { buttons | currentBudgetId = Nothing }
            in
            ( { model | buttons = newButtons, amount = String.split "." amount |> String.join "" }, Cmd.none )

        BudgetList bblAction ->
            let
                ( buttonData, bblCmd, ( addNew, budgetId ) ) =
                    Budgets.update user bblAction model.buttons

                floatAmount =
                    toFloatPoh model.amount / 100.0

                -- UI now renders hidden input
                ( newAmount, addExpenseCmd ) =
                    if addNew && floatAmount > 0.0 then
                        ( "", getNewExpenseCmd user floatAmount budgetId )
                    else
                        ( model.amount, Cmd.none )

                cmd =
                    Cmd.batch
                        [ Cmd.map BudgetList bblCmd
                        , addExpenseCmd
                        ]
            in
            ( { model | amount = newAmount, buttons = buttonData }, cmd )

        UpdateAddedOk expense ->
            let
                newExpenses =
                    expense :: model.expenses

                buttons =
                    model.buttons

                newButtons =
                    { buttons | currentBudgetId = Nothing }
            in
            ( { model | buttons = newButtons, expenses = newExpenses }, Cmd.none )

        UpdateAddedFail error ->
            let
                _ =
                    Debug.log "Expense List: UpdateAddedFail" error
            in
            ( model, Cmd.none )

        -- showing/editing expenses
        Show expense ->
            ( model, Navigation.modifyUrl ("#expenses/" ++ toString expense.id) )

        -- loading and displaying the list
        LoadList ->
            ( model, getExpenses user model.monthNumber )

        LoadListOk expenses ->
            ( { model | expenses = expenses }, Cmd.none )

        LoadListFail error ->
            let
                _ =
                    Debug.log "Expense List: LoadListFail" error
            in
            ( model, Cmd.none )

        -- navigating between months
        LoadPreviousMonth ->
            let
                monthNumber =
                    model.monthNumber - 1
            in
            ( { model | monthNumber = monthNumber }, getExpenses user monthNumber )

        LoadNextMonth ->
            let
                monthNumber =
                    if model.monthNumber < 0 then
                        model.monthNumber + 1
                    else
                        model.monthNumber
            in
            ( { model | monthNumber = monthNumber }, getExpenses user monthNumber )
