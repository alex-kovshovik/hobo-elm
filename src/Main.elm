module Main exposing(..)

import Html.App

import Types exposing (..)
import App.State exposing (initialState, update)
import App.View as App

main : Program (Maybe HoboAuth)
main =
  Html.App.programWithFlags {
    init = initialState,
    view = App.root,
    update = update,
    subscriptions = \_ -> Sub.none
  }
