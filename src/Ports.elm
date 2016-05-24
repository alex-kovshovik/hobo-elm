port module Ports exposing(userData)

import Records exposing (HoboAuth)

port userData : (HoboAuth -> msg) -> Sub msg
