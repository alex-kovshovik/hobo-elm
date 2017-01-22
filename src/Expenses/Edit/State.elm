module Expenses.Edit.State exposing (initialState, update)

import Navigation
import Time
import Date
import Platform.Cmd exposing (map)
import Types exposing (..)
import Expenses.List.Types as Expenses
import Expenses.Edit.Types exposing (..)
import Expenses.Edit.Rest exposing (..)


emptyExpense : Expenses.Expense
emptyExpense =
    let
        pohDate =
            Time.millisecond |> Date.fromTime
    in
        Expenses.Expense 0 0 "" "" 0.0 "" pohDate


initialState : Model
initialState =
    Model emptyExpense "" ""


update : User -> Msg -> Model -> ( Model, Cmd Msg )
update user msg model =
    case msg of
        CommentInput comment ->
            ( { model | comment = comment }, Cmd.none )

        LoadOk expense ->
            ( { model | expense = expense, comment = expense.comment }, Cmd.none )

        LoadFail error ->
            let
                _ =
                    Debug.log "Expenses Edit: LoadFail" error
            in
                ( { model | error = "Error loading the expense" }, Cmd.none )

        Update ->
            let
                e =
                    model.expense

                expense =
                    { e | comment = model.comment }
            in
                ( model, updateExpense user expense )

        UpdateOk result ->
            ( model, Navigation.modifyUrl "#expenses" )

        UpdateFail result ->
            ( { model | error = "Error saving the expense" }, Cmd.none )

        Delete ->
            ( model, deleteExpense user model.expense.id )

        DeleteOk result ->
            ( model, Navigation.modifyUrl "#expenses" )

        DeleteFail error ->
            let
                _ =
                    Debug.log "Expenses Edit: LoadFail" error
            in
                ( { model | error = "Error deleting the expense" }, Cmd.none )

        Cancel ->
            ( model, Navigation.modifyUrl "#expenses" )
