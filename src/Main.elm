module Main exposing(..)

import Navigation

import Types exposing (..)
import App.State exposing (initialState, init, update, urlUpdate)
import App.View as App

import Routes exposing (Route)


main : Program (Maybe HoboAuth)
main =
  Navigation.programWithFlags Routes.parser {
    init = init,
    view = App.root,
    update = update,
    urlUpdate = urlUpdate,
    subscriptions = \_ -> Sub.none
  }
