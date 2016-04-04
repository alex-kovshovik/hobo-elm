module Components.BudgetButton where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import String


-- MODEL
type alias Model = {
  name: String,
  selected: Bool
}


-- UPDATE
type Action
  = Click


update : Action -> Model -> Model
update action model =
  case action of
    Click -> { model | selected = True }


-- VIEW
buttonClass : Model -> Attribute
buttonClass model =
  let
    baseClasses = [ "button", "budget-button" ]
    classes = if model.selected then "selected" :: baseClasses else baseClasses
  in
    class (String.join " " classes)

view : Address Action -> Model -> Html
view address model =
  button [ buttonClass model, onClick address Click ] [ text model.name ]
