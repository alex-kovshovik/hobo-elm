module Utils.Parsers where

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


resultOk : Result a b -> Bool
resultOk result =
  case result of
    Ok value -> True -- Ignore the value
    Err error ->
      let
        errorMessage = Debug.log "resultOk loading/parsing error" error
      in
        False
