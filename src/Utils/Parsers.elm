module Utils.Parsers exposing(..)

import HttpBuilder exposing (..)
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

resultToObject : Result (Error a) (Response a) -> Maybe a
resultToObject objectResult =
  case objectResult of
    Ok response ->
      Just response.data

    Err error ->
      let
        errorMessage = Debug.log "resultToRecord loading/parsing error" error
      in
        Nothing
