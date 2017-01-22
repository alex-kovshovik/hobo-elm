module Budgets.State exposing (..)

import Types exposing (..)
import Budgets.Types exposing (..)
import Budgets.Rest exposing (..)


initialModel : Model
initialModel =
    { budgets = []
    , currentBudgetId = Nothing
    , nextBudgetId = -1
    }


update : User -> Msg -> Model -> ( Model, Cmd Msg, ( Bool, BudgetId ) )
update user msg model =
    case msg of
        Toggle id ->
            let
                ( budgetId, addNew ) =
                    if Just id == model.currentBudgetId then
                        ( Nothing, False )
                    else
                        ( Just id, True )
            in
                ( { model | currentBudgetId = budgetId }, Cmd.none, ( addNew, id ) )

        LoadList ->
            ( model, getBudgets user, ( False, 0 ) )

        LoadListOk budgets ->
            ( { model | budgets = budgets }, Cmd.none, ( False, 0 ) )

        LoadListFail error ->
            let
                _ =
                    Debug.log "Budgets: LoadListFail" error
            in
                ( model, Cmd.none, ( False, 0 ) )
