module App.Rest exposing (checkUser)

import Http
import HttpBuilder exposing (..)
import Json.Decode as Json exposing ((:=))
import Json.Encode
import Task

import Types exposing (..)
import App.Types exposing (..)


checkUser : User -> Cmd Msg
checkUser user =
  let
    userJson = Json.Encode.object [
      ("email", Json.Encode.string user.email),
      ("token", Json.Encode.string user.token)
    ]
  in
    post (authCheckUrl user)
      |> withHeader "Content-Type" "application/json"
      |> withJsonBody userJson
      |> send (jsonReader decodeUser) (jsonReader decodeUser)
      |> Task.toResult
      |> Task.perform UserCheckFail UserCheckOk


authCheckUrl : User -> String
authCheckUrl user =
  Http.url (user.apiBaseUrl ++ "auth/check") []


decodeUser : Json.Decoder CheckData
decodeUser =
  Json.at ["user"] decodeUserFields


decodeUserFields : Json.Decoder CheckData
decodeUserFields =
  Json.object2 (,)
    ( "week_fraction"   := Json.float )
    ( "currency"        := Json.string )
