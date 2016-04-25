module Utils.Parsers where

import Http
import Debug

resultToList : Result a (List b) -> List b
resultToList listResult =
  case listResult of
    Ok list -> list
    Err error ->
      let
        errorMessage = Debug.log "resultToList loading/parsing error" error
      in
        []


httpResultOk : Result Http.RawError Http.Response -> Bool
httpResultOk httpResult =
  case httpResult of
    Ok httpResponse ->
      let
        _ = Debug.log "httpResultOk response" httpResponse
      in
        if httpResponse.status == 200 then True else False
    Err error ->
      let
        errorMessage = Debug.log "httpResultOk loading/parsing error" error
      in
        False
