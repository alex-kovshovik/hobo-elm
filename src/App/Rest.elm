module App.Rest exposing (checkUser)

import App.Types exposing (..)
import Http
import HttpBuilder exposing (..)
import Json.Decode as Json exposing (field)
import Json.Encode
import Task
import Types exposing (..)


checkUser : User -> Cmd Msg
checkUser user =
    let
        userJson =
            Json.Encode.object
                [ ( "email", Json.Encode.string user.email )
                , ( "token", Json.Encode.string user.token )
                ]
    in
    post (authCheckUrl user)
        |> withHeader "Content-Type" "application/json"
        |> withJsonBody userJson
        |> withExpect (Http.expectJson decodeUser)
        |> send handleCheckUser


handleCheckUser : Result Http.Error CheckData -> Msg
handleCheckUser result =
    case result of
        Ok checkData ->
            UserCheckOk checkData

        Err error ->
            UserCheckFail error


authCheckUrl : User -> String
authCheckUrl user =
    user.apiBaseUrl ++ "auth/check"


decodeUser : Json.Decoder CheckData
decodeUser =
    Json.at [ "user" ] decodeUserFields


decodeUserFields : Json.Decoder CheckData
decodeUserFields =
    Json.map2 (,)
        (field "month_fraction" Json.float)
        (field "currency" Json.string)
