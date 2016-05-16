port module Ports exposing(..)

import Components.Login exposing (User)

port userData : (User -> msg) -> Sub msg
