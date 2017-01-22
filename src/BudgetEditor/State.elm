module BudgetEditor.State exposing (update)

import Navigation
import Utils.Numbers exposing (toFloatPoh)
import Types exposing (..)
import Budgets.Types exposing (Model, Budget)
import BudgetEditor.Types exposing (..)
import BudgetEditor.Rest exposing (saveBudgets, deleteBudget)


update : User -> Msg -> Model -> ( Model, Cmd Msg, Bool )
update user msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, False )

        AddMore ->
            let
                newBudget =
                    emptyBudget model.nextBudgetId
            in
                ( { model
                    | nextBudgetId = model.nextBudgetId - 1
                    , budgets = List.append model.budgets [ newBudget ]
                  }
                , Cmd.none
                , False
                )

        InputName id name ->
            let
                _ =
                    Debug.log "InputName" ( id, name )

                modifyBudgetName id name budget =
                    if id == budget.id then
                        { budget | name = name }
                    else
                        budget

                budgets =
                    List.map (modifyBudgetName id name) model.budgets
            in
                ( { model | budgets = budgets }, Cmd.none, False )

        InputAmount id amount ->
            let
                modifyBudgetAmount id amount budget =
                    if id == budget.id then
                        { budget | amount = toFloatPoh amount }
                    else
                        budget

                budgets =
                    List.map (modifyBudgetAmount id amount) model.budgets
            in
                ( { model | budgets = budgets }, Cmd.none, False )

        Save ->
            ( model, saveBudgets user model.budgets, False )

        SaveOk budgets ->
            ( { model | budgets = budgets }, Navigation.modifyUrl "#expenses", False )

        SaveFail error ->
            let
                _ =
                    Debug.log "BudgetEditor: SaveFail" error
            in
                ( model, Cmd.none, False )

        Delete budgetId ->
            let
                fx =
                    if budgetId < 0 then
                        Cmd.none
                    else
                        deleteBudget user budgetId

                budgets =
                    List.filter (\b -> b.id /= budgetId) model.budgets
            in
                ( { model | budgets = budgets }, fx, False )

        DeleteOk result ->
            ( model, Cmd.none, False )

        DeleteFail error ->
            let
                _ =
                    Debug.log "BudgetEditor: DeleteFail" error
            in
                ( model, Cmd.none, False )

        Cancel ->
            ( model, Navigation.modifyUrl "#expenses", True )


emptyBudget : Int -> Budget
emptyBudget budgetId =
    Budget budgetId "" 300.0
