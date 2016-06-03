module App.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html exposing(map)

import App.Types exposing (..)

import Expenses.View


root : Model -> Html Msg
root model =
  div [ class "container"] [
    div [ class "clear col-12 mt1" ] [
      text ("Welcome " ++ model.user.email)
    ],
    div [ class "clear mt1" ] [
      map List (Expenses.View.root model.user model.data)
    ]
  ]
