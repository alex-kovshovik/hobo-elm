module Components.BudgetButtonList exposing(..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Task
import Http
import Json.Decode as Json exposing((:=))

import Records exposing (Budget, Expense, RecordId)
import Messages.BudgetButtonList exposing(..)
import Components.BudgetButton as BudgetButton
import Components.Login exposing (User)
import Utils.Parsers exposing (resultToList)
import Utils.Numbers exposing (toFloatPoh)


-- MODEL
type alias Model = {
  budgets : List Budget,
  currentBudgetId : Maybe RecordId -- one or none can be selected.
}

initialModel : Model
initialModel =
  Model [] Nothing


-- UPDATE
update : User -> Msg -> Model -> (Model, Cmd Msg)
update user msg model =
  case msg of
    Toggle id ->
      let
        currentBudgetId = if Just id == model.currentBudgetId
                            then Nothing
                            else Just id
      in
        ({ model | currentBudgetId = currentBudgetId }, Cmd.none)

    Request ->
      (model, getBudgets user)

    DisplayLoaded budgetsResult ->
      ({ model | budgets = resultToList budgetsResult }, Cmd.none)


-- VIEW
viewBudgetButton: List Expense -> Model -> Budget -> Html Msg
viewBudgetButton expenses model budget =
  div [ class "col-3 bb-cell" ] [
    BudgetButton.view model.currentBudgetId (onClick (Toggle budget.id)) budget expenses
  ]


view : List Expense -> Model -> Html Msg
view expenses model =
  div [ class "clear" ] (List.map (viewBudgetButton expenses model) model.budgets)


-- EFFECTS
-- TODO: change to display failure later
getBudgets : User -> Cmd Msg
getBudgets user =
  Http.get decodeBudgets (budgetsUrl user)
    |> Task.toResult
    |> Task.perform DisplayLoaded DisplayLoaded


budgetsUrl : User -> String
budgetsUrl user =
  Http.url (user.apiBaseUrl ++ "budgets")
    [ ("user_token", user.token),
      ("user_email", user.email) ]


decodeBudgets : Json.Decoder (List Budget)
decodeBudgets =
  Json.at ["budgets"] (Json.list decodeBudget)


decodeBudget : Json.Decoder Budget
decodeBudget =
  Json.object3 convertDecoding
    ( "id"     := Json.int )
    ( "name"   := Json.string )
    ( "amount" := Json.string )


convertDecoding : RecordId -> String -> String -> Budget
convertDecoding id name amount =
  Budget id name (toFloatPoh amount)
