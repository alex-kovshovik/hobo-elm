module Components.Login where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)

-- MODEL
type alias Model = {
  authenticated: Bool,
  authToken: String,
  userName: String
}

-- UPDATE
type Action = NoOp


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model


-- VIEW
view : Address Action -> Model -> Html
view address model =
  div [] [
    text "Login window!"
  ]
