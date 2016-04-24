module Components.Login where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Signal exposing (Address)
import Effects exposing (Effects)
import Task
import Debug

import Http
import Json.Decode as Json exposing((:=))

import Utils.Numbers exposing (onInput)
import Utils.Parsers exposing (resultOk)

-- MODEL
type alias Model = {
  email: String,
  token: String,
  authenticated: Bool
}

type alias AuthResult = {
  result: String,
  message: String
}

-- UPDATE
type Action
  = Login
  | LoginResult (Result Http.Error AuthResult)
  | EmailInput String
  | TokenInput String


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Login ->
      (model, checkLogin model)

    LoginResult result ->
      let
        authenticated = Debug.log "result" (resultOk result)
      in
        ({ model | authenticated = authenticated }, Effects.none)

    EmailInput email ->
      ({ model | email = email}, Effects.none)

    TokenInput token ->
      ({ model | token = token}, Effects.none)


-- VIEW
loginForm : Address Action -> Model -> Html
loginForm address model =
  fieldset [ ] [
    div [ class "field-group" ] [
      label [ for "email" ] [ text "Email" ],
      input [ class "field",
              type' "text",
              id "email",
              name "email",
              value model.email,
              placeholder "Email address",
              onInput address EmailInput ] [ ]
    ],

    div [ class "field-group" ] [
      label [ for "token" ] [ text "Token" ],
      input [ class "field",
              type' "text",
              id "token",
              name "token",
              value model.token,
              placeholder "Authentication token",
              onInput address TokenInput ] [ ]
    ],

    div [ class "field-group" ] [
      button [ class "button", onClick address Login ] [ text "Login" ]
    ]
  ]


view : Address Action -> Model -> Html
view address model =
  loginForm address model


-- EFFECTS
checkLogin : Model -> Effects Action
checkLogin model =
  loginData model
    |> Http.post loginCheckDecoder "http://localhost:3000/auth/check"
    |> Task.toResult
    |> Task.map LoginResult
    |> Effects.task

loginData : Model -> Http.Body
loginData model =
  Http.multipart [
    Http.stringData "email" model.email,
    Http.stringData "token" model.token
  ]

loginCheckDecoder : Json.Decoder AuthResult
loginCheckDecoder =
  Json.object2 AuthResult
    ( "result"  := Json.string )
    ( "message" := Json.string )
