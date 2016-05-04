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
  currentBudgetId : Maybe RecordId -- one or none can be selected.
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
        currentBudgetId = if Just id == model.currentBudgetId
                            then Nothing
                            else Just id
      in
        ({ model | currentBudgetId = currentBudgetId }, Effects.none)

    Request ->
      (model, getBudgets user)

    DisplayLoaded budgetsResult ->
      ({ model | budgets = resultToList budgetsResult }, Effects.none)


-- VIEW
viewBudgetButton: Address Action -> Model -> Budget -> Html
viewBudgetButton address model budget =
  li [ ] [
    BudgetButton.view model.currentBudgetId (onClick address (Toggle budget.id)) budget
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
  Http.url (user.apiBaseUrl ++ "budgets")
  -- Http.url "http://api.hoboapp.com/budgets"
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
