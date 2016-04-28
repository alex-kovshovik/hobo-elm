module Components.BudgetButtonList where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Task
import Effects exposing (Effects)
import Http
import Json.Decode as Json exposing((:=))

import Records exposing (Budget, RecordId)
import Components.BudgetButton as BudgetButton
import Components.Login exposing (User)
import Utils.Parsers exposing (resultToList)


-- MODEL
type alias Model = {
  budgets : List Budget,
  currentBudget : Maybe Budget -- one or none can be selected.
}

initialModel : Model
initialModel =
  Model [] Nothing


-- UPDATE
type Action
  = Toggle RecordId
  | Request
  | DisplayLoaded (Result Http.Error (List Budget))


update : User -> Action -> Model -> (Model, Effects Action)
update user action model =
  case action of
    Toggle id ->
      let
        clickedBudgets = List.filter (\budget -> budget.id == id) model.budgets
        clickedBudget = List.head clickedBudgets

        currentBudget = if model.currentBudget == clickedBudget
                          then Nothing
                          else clickedBudget
      in
        ({ model | currentBudget = currentBudget }, Effects.none)

    Request ->
      (model, getBudgets user)

    DisplayLoaded budgetsResult ->
      ({ model | budgets = resultToList budgetsResult }, Effects.none)


-- VIEW
viewBudgetButton: Address Action -> Model -> Budget -> Html
viewBudgetButton address model budget =
  li [ ] [
    BudgetButton.view model.currentBudget (onClick address (Toggle budget.id)) budget
  ]


view : Address Action -> Model -> Html
view address model =
  ul [ class "list-unstyled list-inline" ] (List.map (viewBudgetButton address model) model.budgets)


-- EFFECTS
getBudgets : User -> Effects Action
getBudgets user =
  Http.get decodeBudgets (budgetsUrl user)
    |> Task.toResult
    |> Task.map DisplayLoaded
    |> Effects.task


budgetsUrl : User -> String
budgetsUrl user =
  Http.url "http://localhost:3000/budgets"
    [ ("user_token", user.token),
      ("user_email", user.email) ]


decodeBudgets : Json.Decoder (List Budget)
decodeBudgets =
  Json.at ["budgets"] (Json.list decodeBudget)


decodeBudget : Json.Decoder Budget
decodeBudget =
  Json.object2 Budget
    ( "id"     := Json.int )
    ( "name"   := Json.string )
