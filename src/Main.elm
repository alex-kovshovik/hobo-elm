module Main exposing (..)

import Navigation
import Types exposing (..)
import App.State exposing (initialState, init, update)
import App.View as App
import App.Types exposing (Model, Msg(..))
import Routes exposing (Route)


main : Program (Maybe HoboAuth) Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , update = update
        , view = App.root
        , subscriptions = \_ -> Sub.none
        }
