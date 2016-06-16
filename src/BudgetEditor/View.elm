module BudgetEditor.View exposing (root)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Types exposing (..)
import Budgets.Types exposing (Model)
import BudgetEditor.Types exposing (..)

root : User -> Model -> Html Msg
root user model =
  div [ ] [
    div [ class "col-12" ] [
      text "Budget editor is going to be here!"
    ],

    div [ class "clear" ] [
      button [ class "button", onClick Cancel ] [ text "Cancel" ]
    ]
  ]
