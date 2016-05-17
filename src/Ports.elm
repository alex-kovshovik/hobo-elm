port module Ports exposing(userData)

import Components.Login exposing (User)

port userData : (User -> msg) -> Sub msg
